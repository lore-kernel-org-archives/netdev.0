From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH 11/13] mac68k: macmace fixes
Date: Sun, 18 Mar 2007 13:26:37 +1100 (EST)
Message-ID: <Pine.LNX.4.64.0703181208490.11593@loopy.telegraphics.com.au>
References: <Pine.LNX.4.64.0703171732250.4875@loopy.telegraphics.com.au>
 <20070317153054.GC14763@cynthia.pants.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: Brad Boyer <flar@allandria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loopy.telegraphics.com.au ([202.45.126.152]:42830 "EHLO
	loopy.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbXCRC0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2007 22:26:39 -0400
In-Reply-To: <20070317153054.GC14763@cynthia.pants.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 17 Mar 2007, Brad Boyer wrote:

> On Sat, Mar 17, 2007 at 08:08:33PM +1100, Finn Thain wrote:
> > Index: linux-2.6.20/drivers/net/Kconfig
> > ===================================================================
> > --- linux-2.6.20.orig/drivers/net/Kconfig	2007-03-06 19:22:38.000000000 +1100
> > +++ linux-2.6.20/drivers/net/Kconfig	2007-03-06 20:15:52.000000000 +1100
> > @@ -347,8 +347,8 @@ config MACSONIC
> >  	  be called macsonic.
> >  
> >  config MACMACE
> > -	bool "Macintosh (AV) onboard MACE ethernet (EXPERIMENTAL)"
> > -	depends on NET_ETHERNET && MAC && EXPERIMENTAL
> > +	bool "Macintosh (AV) onboard MACE ethernet"
> > +	depends on NET_ETHERNET && MAC
> >  	select CRC32
> >  	help
> >  	  Support for the onboard AMD 79C940 MACE Ethernet controller used in
> 
> Have you tried making this a tristate option? It looked like the code 
> had all the proper hooks to be built as a module, but it currently isn't 
> allowed by the Kconfig.

Yes, I tried it. The problem was the psc global, which wouldn't allow it 
to link as a module. So this patch just focuses on getting the driver 
working, which is what the debian devs needed. I wasn't particularly 
concerned with enhancements, so I just left MACMACE as a boolean.

Even though no other code uses the PSC's DMA engine, there's probably an 
argument for making the Peripheral Controller Chip a device in it's own 
right. (Well, it serves as the interrupt controller too. And there are 
other patches in this series that fix the PSC interrupt problems.)

Modernization needs to happen, but I'm just trying to fix borken stuff 
because I think that needs to happen first.

-f

> 
> 	Brad Boyer
> 	flar@allandria.com
> 
