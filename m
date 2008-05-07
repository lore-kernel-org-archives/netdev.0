From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Remove cli()/sti() calls from HYSDN driver.
Date: Wed, 7 May 2008 15:38:00 -0700
Message-ID: <20080507153800.16537fbc.akpm@linux-foundation.org>
References: <1209673012-10500-1-git-send-email-mark.asselstine@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	kkeil@suse.de, asselsm@gmail.com, mark.asselstine@windriver.com
To: Mark Asselstine <mark.asselstine@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32820 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752059AbYEGWid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 18:38:33 -0400
In-Reply-To: <1209673012-10500-1-git-send-email-mark.asselstine@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 May 2008 16:16:52 -0400
Mark Asselstine <mark.asselstine@windriver.com> wrote:

> >From looking at this driver the use of cli()/sti() within the do/while
> was a way to ensure interrupts were only disabled for short periods of
> time while the bulk of the time interrupts were free to occur. The
> use of the spin lock has eliminated the need to play with interrupts
> in this way while still allowing for IO to be protected.

OK.  If we still want the interrupt-latency optimisation then we should
switch over to using local_irq_disable().  But probably nobody cares.

> The remaining 3 sti() calls seem unneeded now that at no other point
> in the driver is there a call to cli().
> 
> Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
> ---
>  drivers/isdn/hysdn/boardergo.c |   14 +++++---------

So... can we now do this?


--- a/drivers/isdn/hysdn/Kconfig~a
+++ a/drivers/isdn/hysdn/Kconfig
@@ -3,7 +3,7 @@
 #
 config HYSDN
 	tristate "Hypercope HYSDN cards (Champ, Ergo, Metro) support (module only)"
-	depends on m && PROC_FS && PCI && BROKEN_ON_SMP
+	depends on m && PROC_FS && PCI
 	help
 	  Say Y here if you have one of Hypercope's active PCI ISDN cards
 	  Champ, Ergo and Metro. You will then get a module called hysdn.
_

