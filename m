From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Submission for S2io 10GbE driver
Date: Thu, 26 Feb 2004 02:40:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403DA300.1010005@pobox.com>
References: <4223A04BF7D1B941A25246ADD0462FF50115A824@blr-m3-msg.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: leonid.grossman@s2io.com, netdev@oss.sgi.com, raghavendra.koushik@s2io.com,
        ravinandan.arakali@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@wipro.com
In-Reply-To: <4223A04BF7D1B941A25246ADD0462FF50115A824@blr-m3-msg.wipro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

raghavendra.koushik@wipro.com wrote:
> Jeff,
> 	some questions on few of your comments.
> 
> 
>>>30) do not call netif_stop_queue() and netif_wake_queue() on link
>>>events, in s2io_link.  Simply call netif_carrier_{on,off}.
> 
> 
> When link goes down and I just call netif_carrier_off the upper layer
> still continues to send packets to the s2io_xmit routine. In order to
> avoid this, I stop the queue and a corresponding wake when link returns.
> Is there any particular reason why this should be avoided?

Ignore me on this one, I am incorrect.


>>>28) are you aware that all of s2io_tx_watchdog is inside the
>>>dev->tx_lock spinlock?  I am concern s2io_tx_watchdog execution time may
>>>be quite excessive a duration to hold a spinlock.
> 
> 
> Actually no. The intention is to reset the NIC and re-initialize it in the
> tx_watchdog function and I'am not sure how else to do this.
> Do you foresee a problem with the current method, because for most part of
> the function the queue would be in a stopped state (the netif_stop_queue is
> called right on top of s2io_close and the queue is woken up at almost
> the end of s2io_open).

It is incorrect to perform any slow operation inside spin_lock_bh().

You can schedule_work() to perform the actual reset, for example, to get 
around this.


>>>29) never call netif_wake_queue() unconditionally.  only call it if you
>>>are 100% certain that the net stack is allowed to add another packet to
>>>your hardware's TX queue(s).
> 
> 
> I wake the queue in txIntrHandler without checking anything because at this
> point I'am certain that some free transmit descriptors are available for
> new xmit. The tx Interrupt arrives only after one or more Tx descriptor and
> buffer were successfully DMA'ed to the NIC and the ownership of these
> descriptor(s) is returned to the host.

OK, all good then.

	Jeff
