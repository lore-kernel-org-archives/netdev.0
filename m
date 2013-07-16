From: Dinh Nguyen <dinguyen@altera.com>
Subject: Re: [PATCH] phy: micrel: Add definitions for common Micrel PHY
 registers
Date: Tue, 16 Jul 2013 09:54:37 -0500
Message-ID: <1373986477.3164.1.camel@linux-builds1>
References: <1373929730-28130-1-git-send-email-dinguyen@altera.com>
	 <51E5046C.60101@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <dinh.linux@gmail.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Guo <shawn.guo@linaro.org>,
	Andrew Victor <linux@maxim.org.za>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Pavel Machek <pavel@denx.de>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe003.messaging.microsoft.com ([207.46.163.26]:17348
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932717Ab3GPOyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 10:54:44 -0400
In-Reply-To: <51E5046C.60101@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 10:29 +0200, Nicolas Ferre wrote:
> On 16/07/2013 01:08, dinguyen@altera.com :
> > From: Dinh Nguyen <dinguyen@altera.com>
> >
> > Add defines for common Micrel PHY setups so that other platforms
> > can use them. Update imx61 and sama5 hardware to use the micrel_phy.h
> > PHY defines.
> >
> > Also add support for the KSZ9021RLRN PHY.
> >
> > Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
> > Cc: David S. Miller <davem@davemloft.net>
> > Cc: Shawn Guo <shawn.guo@linaro.org>
> > CC: Andrew Victor <linux@maxim.org.za>
> > CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> BTW, which way do you plan to use to merge it upstream?

Thanks Nicolas, I was hoping to have either Shawn or you pick it up?

Dinh
> 
> Thanks a lot, bye,
> 
> > CC: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
> > CC: Pavel Machek <pavel@denx.de>
> > ---
> >   arch/arm/mach-at91/board-dt-sama5.c |   17 ++++++-----------
> >   arch/arm/mach-imx/mach-imx6q.c      |   13 ++++++++-----
> >   include/linux/micrel_phy.h          |    6 ++++++
> >   3 files changed, 20 insertions(+), 16 deletions(-)
> >
> > diff --git a/arch/arm/mach-at91/board-dt-sama5.c b/arch/arm/mach-at91/board-dt-sama5.c
> > index ad95f6a..bf00d15 100644
> > --- a/arch/arm/mach-at91/board-dt-sama5.c
> > +++ b/arch/arm/mach-at91/board-dt-sama5.c
> > @@ -42,20 +42,15 @@ static int ksz9021rn_phy_fixup(struct phy_device *phy)
> >   {
> >   	int value;
> >
> > -#define GMII_RCCPSR	260
> > -#define GMII_RRDPSR	261
> > -#define GMII_ERCR	11
> > -#define GMII_ERDWR	12
> > -
> >   	/* Set delay values */
> > -	value = GMII_RCCPSR | 0x8000;
> > -	phy_write(phy, GMII_ERCR, value);
> > +	value = MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW | 0x8000;
> > +	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
> >   	value = 0xF2F4;
> > -	phy_write(phy, GMII_ERDWR, value);
> > -	value = GMII_RRDPSR | 0x8000;
> > -	phy_write(phy, GMII_ERCR, value);
> > +	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
> > +	value = MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW | 0x8000;
> > +	phy_write(phy, MICREL_KSZ9021_EXTREG_CTRL, value);
> >   	value = 0x2222;
> > -	phy_write(phy, GMII_ERDWR, value);
> > +	phy_write(phy, MICREL_KSZ9021_EXTREG_DATA_WRITE, value);
> >
> >   	return 0;
> >   }
> > diff --git a/arch/arm/mach-imx/mach-imx6q.c b/arch/arm/mach-imx/mach-imx6q.c
> > index 7be13f8..c8d7814 100644
> > --- a/arch/arm/mach-imx/mach-imx6q.c
> > +++ b/arch/arm/mach-imx/mach-imx6q.c
> > @@ -103,13 +103,16 @@ static int ksz9021rn_phy_fixup(struct phy_device *phydev)
> >   {
> >   	if (IS_BUILTIN(CONFIG_PHYLIB)) {
> >   		/* min rx data delay */
> > -		phy_write(phydev, 0x0b, 0x8105);
> > -		phy_write(phydev, 0x0c, 0x0000);
> > +		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW);
> > +		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
> >
> >   		/* max rx/tx clock delay, min rx/tx control delay */
> > -		phy_write(phydev, 0x0b, 0x8104);
> > -		phy_write(phydev, 0x0c, 0xf0f0);
> > -		phy_write(phydev, 0x0b, 0x104);
> > +		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
> > +		phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
> > +		phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW);
> >   	}
> >
> >   	return 0;
> > diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
> > index 8752dbb..ad05ce6 100644
> > --- a/include/linux/micrel_phy.h
> > +++ b/include/linux/micrel_phy.h
> > @@ -17,6 +17,7 @@
> >
> >   #define PHY_ID_KSZ8873MLL	0x000e7237
> >   #define PHY_ID_KSZ9021		0x00221610
> > +#define PHY_ID_KSZ9021RLRN	0x00221611
> >   #define PHY_ID_KS8737		0x00221720
> >   #define PHY_ID_KSZ8021		0x00221555
> >   #define PHY_ID_KSZ8031		0x00221556
> > @@ -35,4 +36,9 @@
> >   /* struct phy_device dev_flags definitions */
> >   #define MICREL_PHY_50MHZ_CLK	0x00000001
> >
> > +#define MICREL_KSZ9021_EXTREG_CTRL	0xB
> > +#define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
> > +#define MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SCEW	0x104
> > +#define MICREL_KSZ9021_RGMII_RX_DATA_PAD_SCEW	0x105
> > +
> >   #endif /* _MICREL_PHY_H */
> >
> 
> 
