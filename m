From: Ingo Molnar <mingo@elte.hu>
Subject: [PATCH] net, wd.c: fix undefined reference to `NS8390p_init'
Date: Mon, 11 Aug 2008 11:11:05 +0200
Message-ID: <20080811091105.GA8141@elte.hu>
References: <20080806182828.6bfe0a16.sfr@canb.auug.org.au> <20080806172148.7fac5999.randy.dunlap@oracle.com> <Pine.LNX.4.64.0808070918510.17614@anakin> <20080807102931.1bb0607d@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080807102931.1bb0607d@lxorguk.ukuu.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Thu, 7 Aug 2008 09:20:07 +0200 (CEST)
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> 
> > On Wed, 6 Aug 2008, Randy Dunlap wrote:
> > > One randconfig ends with:
> > > 
> > > drivers/built-in.o: In function `wd_probe1':
> > > wd.c:(.init.text+0x6179): undefined reference to `NS8390p_init'
> > > make[1]: *** [.tmp_vmlinux1] Error 1
> > 
> > drivers/net/Makefile has:
> > 
> > obj-$(CONFIG_WD80x3) += wd.o 8390.o
> > 
> > So either wd_probe1() should call NS8390_init(), or obj-$(CONFIG_WD80x3)
> > should link with 8390p.o. Don't know which is the appropriate change
> > here (my gut feeling says the latter).
> 
> Safest is the latter. The shared memory interface on the wd is full 
> speed 8 or 16bit (depending on card/jumpers) but I'm not clear about 
> the NIC. Most of the performance hit is on the packet transfer which 
> is private methods on this device so using 8390p won't make a big 
> difference on this board anyway.

Alan, Jeff, i triggered this too with latest -git, please pick up the 
fix below if you dont have it already.

	Ingo

------------------>
>From c03cb1727bb4c5433436bfb0fab59fdcc00749c3 Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 11 Aug 2008 11:11:42 +0200
Subject: [PATCH] net, wd.c: fix undefined reference to `NS8390p_init'

fix:

  drivers/built-in.o: In function `wd_probe1':
  wd.c:(.init.text+0xb247): undefined reference to `NS8390p_init'

that triggers with:

  http://redhat.com/~mingo/misc/config-Mon_Aug_11_10_40_46_CEST_2008.bad

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7629c90..dc6dbf6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -106,7 +106,7 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
-obj-$(CONFIG_WD80x3) += wd.o 8390.o
+obj-$(CONFIG_WD80x3) += wd.o 8390p.o
 obj-$(CONFIG_EL2) += 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
