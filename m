From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH v2] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 27 Aug 2014 22:19:22 +0200
Message-ID: <33554745.SgNonHnYhV@diego>
References: <1409122527-17673-1-git-send-email-romain.perier@gmail.com> <3619843.a6HHkMsuOu@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Romain Perier <romain.perier@gmail.com>,
	linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:59833 "EHLO gloria.sntech.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935713AbaH0URY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 16:17:24 -0400
In-Reply-To: <3619843.a6HHkMsuOu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 27. August 2014, 22:11:29 schrieb Arnd Bergmann:
> On Wednesday 27 August 2014 06:55:27 Romain Perier wrote:
> > This patch defines a platform glue layer for Rockchip SoCs which
> > support arc-emac driver. It ensures that regulator for the rmii is on
> > before trying to connect to the ethernet controller. It applies right
> > speed and mode changes to the grf when ethernet settings change.
> > 
> > Signed-off-by: Romain Perier <romain.perier@gmail.com>
> > ---
> > 
> >  drivers/net/ethernet/arc/Kconfig         |  15 +++
> >  drivers/net/ethernet/arc/Makefile        |   1 +
> >  drivers/net/ethernet/arc/emac.h          |   2 +
> >  drivers/net/ethernet/arc/emac_main.c     |   2 +
> >  drivers/net/ethernet/arc/emac_rockchip.c | 224
> >  +++++++++++++++++++++++++++++++ 5 files changed, 244 insertions(+)
> >  create mode 100644 drivers/net/ethernet/arc/emac_rockchip.c
> > 
> > diff --git a/drivers/net/ethernet/arc/Kconfig
> > b/drivers/net/ethernet/arc/Kconfig index 89e04fd..6d96a82 100644
> > --- a/drivers/net/ethernet/arc/Kconfig
> > +++ b/drivers/net/ethernet/arc/Kconfig
> > @@ -32,4 +32,19 @@ config ARC_EMAC
> > 
> >  	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
> >  	  Say Y here if you have such a board.  If unsure, say N.
> > 
> > +config EMAC_ROCKCHIP
> > +       tristate "Rockchip EMAC support"
> > +       select ARC_EMAC_CORE
> > +       depends on OF_IRQ
> > +       depends on OF_NET
> > +       depends on ARCH_ROCKCHIP
> > +       depends on REGULATOR_ACT8865
> > +       depends on SMSC_PHY
> > +       depends on MFD_SYSCON
> 
> You should generally not add 'depends on' for specific drivers out
> of a subsystems. Just list the build-time dependencies, like
> 
> 	depends on OF_IRQ && OF_NET && PHYLIB && REGULATOR && MFD_SYSCON

in this case even MFD_SYSCON can go away, as the syscon functions provide 
stubs for !MFD_SYSCON .


[...]

> > +	rate = 50000000;
> 
> Where does this number come from?

The RMII interface needs always a rate of 50MHz ... my questions would be why 
the 50000000 are not in the clk_set_rate directly and need an extra var :-)



Heiko
