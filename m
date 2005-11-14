From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH 6/15] misc: Trim non-IPX builds
Date: Mon, 14 Nov 2005 02:57:07 +0100
Message-ID: <20051114015707.GB5735@stusta.de>
References: <6.282480653@selenic.com> <7.282480653@selenic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750727AbVKNB5K@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>, acme@conectiva.com.br
Content-Disposition: inline
In-Reply-To: <7.282480653@selenic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2005 at 02:35:51AM -0600, Matt Mackall wrote:
> trivial: drop unused 802.3 code if we compile without IPX
> 
> (originally from http://wohnheim.fh-wedel.de/~joern/software/kernel/je/25/)
> 
> Signed-off-by: Matt Mackall <mpm@selenic.com>
> 
> Index: tiny/net/802/Makefile
> ===================================================================
> --- tiny.orig/net/802/Makefile	2005-03-15 00:24:59.000000000 -0600
> +++ tiny/net/802/Makefile	2005-03-15 00:25:48.000000000 -0600
> @@ -2,8 +2,6 @@
>  # Makefile for the Linux 802.x protocol layers.
>  #
>  
> -obj-y			:= p8023.o
> -
>  # Check the p8022 selections against net/core/Makefile.
>  obj-$(CONFIG_SYSCTL)	+= sysctl_net_802.o
>  obj-$(CONFIG_LLC)	+= p8022.o psnap.o
> @@ -11,5 +9,5 @@ obj-$(CONFIG_TR)	+= p8022.o psnap.o tr.o
>  obj-$(CONFIG_NET_FC)	+=                 fc.o
>  obj-$(CONFIG_FDDI)	+=                 fddi.o
>  obj-$(CONFIG_HIPPI)	+=                 hippi.o
> -obj-$(CONFIG_IPX)	+= p8022.o psnap.o
> +obj-$(CONFIG_IPX)	+= p8022.o psnap.o p8023.o
>  obj-$(CONFIG_ATALK)	+= p8022.o psnap.o

This patch isn't bad, but looking closer we could move the contents of 
p8023.c as well as the contents of at least p8022.c and pe2.c into 
af_ipx.c.

Is the contents of any of these three files expected to be used
outside IPX (closest candidate would be appletalk)?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
