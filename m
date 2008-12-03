From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: m68k 8390 breakage (was: Re: linux-next: Tree for December 3)
Date: Wed, 3 Dec 2008 21:38:41 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812032135220.10635@anakin>
References: <20081203183602.c06f8c39.sfr@canb.auug.org.au>
 <Pine.LNX.4.64.0812032042480.10635@anakin> <20081203115622.50256091@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yergi.telenet-ops.be ([195.130.132.36]:40838 "EHLO
	yergi.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759394AbYLCUjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 15:39:17 -0500
In-Reply-To: <20081203115622.50256091@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Dec 2008, Stephen Hemminger wrote:
> On Wed, 3 Dec 2008 20:49:39 +0100 (CET)
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> 
> > On Wed, 3 Dec 2008, Stephen Rothwell wrote:
> > > Status of my local build tests will be at
> > > http://kisskb.ellerman.id.au/linux-next .  If maintainers want to give
> > > advice about cross compilers/configs that work, we are always open to add
> > > more builds.
> > 
> > Since a few days, m68k defconfig and allmodconfig give:
> > 
> > | drivers/net/lib8390.c:1014: undefined reference to `ei_start_xmit'
> > | drivers/net/lib8390.c:1015: undefined reference to `ei_get_stats'
> > | drivers/net/lib8390.c:1016: undefined reference to `ei_set_multicast_list'
> > 
> > (cfr. e.g. http://kisskb.ellerman.id.au/kisskb/buildresult/58795/)
> > 
> > git bisect run on "make ARCH=m68k mac_defconfig vmlinux" tells me:
> > 
> > 8884c092e5e4f9a1b6e44f2e02a3eb5481af87ab is first bad commit
> > commit 8884c092e5e4f9a1b6e44f2e02a3eb5481af87ab
> > Author: Stephen Hemminger <shemminger@vyatta.com>
> > Date:   Tue Nov 25 18:12:49 2008 -0800
> > 
> >     8390: add common net_device ops
> > 
> >     Fix the defactoring of ei_XXX functions in 8390 and 8390p.
> >     Remove the tx_timeout hack since no driver including the 3c503
> >     overrides tx_timeout at this time, looks like a legacy thing.
> > 
> >     Also, since several drivers all have same hooks, provide common
> >     netdev_ops.
> > 
> >     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Which driver is having problem

Oops, the log above is from allmodconfig and indeed doesn't show it.

mac_defconfig (which has CONFIG_MAC8390=y) shows more info:

| drivers/net/lib8390.c:303: warning: '__ei_start_xmit' defined but not used
| drivers/net/lib8390.c:881: warning: '__ei_get_stats' defined but not used
| drivers/net/lib8390.c:990: warning: '__ei_set_multicast_list' defined but not
| ...
| drivers/built-in.o: In function `ethdev_setup':
| mac8390.c:(.text+0x29684): undefined reference to `ei_start_xmit'
| mac8390.c:(.text+0x2968c): undefined reference to `ei_get_stats'
| mac8390.c:(.text+0x29694): undefined reference to `ei_set_multicast_list'

defconfig log at http://kisskb.ellerman.id.au/kisskb/buildresult/58646/

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
