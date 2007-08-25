From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] DM9000: fix interface hang under load
Date: Sat, 25 Aug 2007 00:40:52 -0400
Message-ID: <46CFB2D4.4010801@pobox.com>
References: <20070820233342.GG9315@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42168 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbXHYElH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:41:07 -0400
In-Reply-To: <20070820233342.GG9315@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal wrote:
> When transferring data at full speed, the DM9000 network interface
> sometimes stops sending/receiving data. Worse, ksoftirqd consumes
> 100% cpu and the net tx watchdog never triggers.
> Fix by spin_lock_irqsave() in dm9000_start_xmit() to prevent the
> interrupt handler from interfering.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Actually the comments ('Disable all interrupts, iow(db, DM9000_IMR, IMR_PAR) etc)
>  give the impression that the interrupt handler cannot run during dm9000_start_xmit(),
>  however this isn't correct (perhaps the chipset has some weird timing issues?).
>  The interface lockup usually occurs between 30 and 360 seconds after starting transmitting
>  data (netcat /dev/zero) at full speed; with this patch applied I haven't been able
>  to reproduce hangs yet (ran for > 2h).
>  FTR: This is a dm9000 on XScale-PXA255 rev 6 (ARMv5TE)/Compulab CM-x255, i.e.
>  a module not supported by the vanilla kernel. Tested on (patched) 2.6.18.
> 
>  dm9000.c |   25 +++++++------------------
>  1 file changed, 7 insertions(+), 18 deletions(-)

applied


