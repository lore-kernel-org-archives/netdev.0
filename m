From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 19 Dec 2004 23:29:43 +0100
Message-ID: <41C600D7.70005@tpack.net>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com> <1103484552.1046.155.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com, Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1103484552.1046.155.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2004-12-15 at 10:03, Thomas Spatzier wrote:
> 
>>jamal <hadi@cyberus.ca> wrote on 15.12.2004 14:50:27:
>>
>>
>>>When you netif_stop_queue you should never receive packets anymore
>>>at the device level. If you receive any its a bug and you should drop
>>>them and bitch violently. In other words i think what you have at the
>>>moment is bandaid not the solution.
>>
>>When we do a netif_stop_queue, we do not get any more packets.
>>So this behaviour is ok. The problem is that the socket write
>>queues fill up then and get blocked as soon as they are full.
>>
> 
> This is the strange part. Anyone still willing to provide a sample
> program that hangs?

I haven't tried this myself, but surely it can happen when the
socket send-buffer is smaller than what can be queued up for
transmission: i.e. in the qdisc queue and device DMA ring.
And even more so, when sending to multiple devices from one socket.

> Look at e1000 they do it right there. 
> 
> On link up:
> 	netif_carrier_on(netdev);
> 	netif_wake_queue(netdev);
> On Link Down:
> 	netif_carrier_off(netdev); // wonder if these need swapping
> 	netif_stop_queue(netdev);
> 

Well, this is the same as what started this whole thread.
I believe that stopping the queue on link-down events is simply
bad behavior of the driver.

-Tommy
