From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 15:31:46 -0800
Message-ID: <20061214153146.52d5de40@freekitty>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty>
	<87odq6azel.fsf@sycorax.lbl.gov>
	<20061214144734.03300fa6@freekitty>
	<87zm9qkqsj.fsf@sycorax.lbl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:42111 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933AbWLNXbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 18:31:48 -0500
To: Alex Romosan <romosan@sycorax.lbl.gov>
In-Reply-To: <87zm9qkqsj.fsf@sycorax.lbl.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 15:21:00 -0800
Alex Romosan <romosan@sycorax.lbl.gov> wrote:

> Stephen Hemminger <shemminger@osdl.org> writes:
> 
> > Another useful bit of information is the statistics (ethtool -S eth0).
> > When there were flow control bugs, they would show up as count of 1.
> 
> the driver locked up again, even with msi interrupts disabled and
> idle_timeout=10. the console message was pretty much as before:
> 
> kernel: NETDEV WATCHDOG: eth0: transmit timed out
> kernel: sky2 eth0: tx timeout
> kernel: sky2 eth0: transmit ring 336 .. 296 report=336 done=336
> kernel: sky2 hardware hung? flushing
> kernel: NETDEV WATCHDOG: eth0: transmit timed out
> kernel: sky2 eth0: tx timeout
> kernel: sky2 eth0: transmit ring 296 .. 255 report=336 done=336
> kernel: sky2 status report lost?
> 
> and this is the output from ethtool -S:
> 
> NIC statistics:
>      tx_bytes: 3092123897
>      rx_bytes: 546577898
>      tx_broadcast: 20
>      rx_broadcast: 4376
>      tx_multicast: 0
>      rx_multicast: 459
>      tx_unicast: 2585993
>      rx_unicast: 1550758
>      tx_mac_pause: 1

If this is repeatable... and mac_pause is always one then the
problem is hardware flow control.  I saw bugs before in the bus
interface where it would not resume on unaligned buffer, but
that was on receive.
