From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] NF_CONNTRACK_H323 must depend on (IPV6 || IPV6=n)
Date: Mon, 29 Jan 2007 01:00:11 +0100
Message-ID: <20070129000011.GB6017@stusta.de>
References: <20070127234928.64d8e437.akpm@osdl.org> <20070128114148.b8067721.randy.dunlap@oracle.com> <20070128222136.GZ6017@stusta.de> <20070128.155348.39160134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: randy.dunlap@oracle.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netfilter@lists.netfilter.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:42770 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932927AbXA2AAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 19:00:04 -0500
Content-Disposition: inline
In-Reply-To: <20070128.155348.39160134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 28, 2007 at 03:53:48PM -0800, David Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Sun, 28 Jan 2007 23:21:37 +0100
> 
> > On Sun, Jan 28, 2007 at 11:41:48AM -0800, Randy Dunlap wrote:
> > >...
> > > net/built-in.o: In function `q931_help':
> > > nf_conntrack_h323_main.c:(.text.q931_help+0x6ad): undefined reference to `ip6_route_output'
> > > nf_conntrack_h323_main.c:(.text.q931_help+0x6c3): undefined reference to `ip6_route_output'
> > >...
> > 
> > You didn't send your .config, but it seems you had CONFIG_IPV6=m and
> > CONFIG_NF_CONNTRACK_H323=y.
> > 
> > In this case, the untested patch below should fix it.
> > 
> > > ~Randy
> > 
> > cu
> > Adrian
> > 
> > 
> > <--  snip  -->
> > 
> > 
> > CONFIG_IPV6=m, CONFIG_NF_CONNTRACK_H323=y results in a compile error.
> > 
> > Fix this by letting NF_CONNTRACK_H323 depend on (IPV6 || IPV6=n).
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Adrian is this the correct way to constrain the selection between
> "n" and "m" in this kind of situation?  I thought doing something
> like "depends on IPV6" is sufficient to achieve that?

"depends on IPV6" would fix the bug - but it would also make 
NF_CONNTRACK_H323 unavailable for all people without IPV6 support in 
their kernel.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

