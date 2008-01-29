From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: appearing again: kernel: eth0: too many iterations (6) in nv_nic_irq
Date: Mon, 28 Jan 2008 20:07:06 -0500
Message-ID: <20080129010706.GC21912@gospo.usersys.redhat.com>
References: <18333.55687.621653.838538@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbYA2BHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 20:07:10 -0500
Content-Disposition: inline
In-Reply-To: <18333.55687.621653.838538@fisica.ufpr.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 11:32:55AM -0200, Carlos Carvalho wrote:
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


I've noticed that when running the latest forcedeth on an older base
kernel (2.6.18 in my case) that enable_irq and disable_irq don't quite
behave the same way with using MSI as they do with INTx.  2.6.24 works
great on the same hardware so something has changed between at leat
2.6.18 and now to make life better.  I've been meaning to look at those
calls and figure out if we can replace them with simple calls to disable
the hardware IRQs only, but haven't had a chance yet.

