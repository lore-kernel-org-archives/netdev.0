From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: appearing again: kernel: eth0: too many iterations (6) in
 nv_nic_irq
Date: Mon, 28 Jan 2008 08:06:56 -0800
Message-ID: <20080128080656.1cc8a4e0@deepthought>
References: <18333.55687.621653.838538@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: carlos@fisica.ufpr.br (Carlos Carvalho)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53983 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528AbYA1QHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 11:07:00 -0500
In-Reply-To: <18333.55687.621653.838538@fisica.ufpr.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jan 2008 11:32:55 -0200
carlos@fisica.ufpr.br (Carlos Carvalho) wrote:

> It seems that this problem with NVidia's nic comes up more and more...
> From time to time we get this in the log:
> 
> Jan 27 14:43:12 duvel kernel: eth0: too many iterations (6) in nv_nic_irq.
> 
> We algo get
> 
> Jan 27 11:32:43 duvel kernel: KERNEL: assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)
> 
> But at different moments, as shown above. Are they related? What's the
> meaning of the "assertion failed" one?
> 
> The messages are more likely to appear when traffic is high
> (>500Mb/s). This is with 2.6.22.16.
> 
> Any suggestions?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Use NAPI which is available as configuration option in this driver.

Increase the max_interrupt_work from the ridiculously low value of 5
to something more larger like 15, with module parameter in /etc/modprobe.d/options:

options forcedeth max_interrupt_work=15

Also, see if you motherboard supports MSI, if so add "msi=1" module parameter

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
