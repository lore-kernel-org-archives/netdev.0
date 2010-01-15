From: "Liu Yu-B13201" <B13201@freescale.com>
Subject: RE: [PATCH 4/4] phy: add RTBI mode for m88e1111
Date: Fri, 15 Jan 2010 10:49:37 +0800
Message-ID: <0A1FE637C2C7E148B9573BB60CC630E5711B54@zch01exm26.fsl.freescale.net>
References: <1263456799-3306-1-git-send-email-yu.liu@freescale.com> <1263456799-3306-2-git-send-email-yu.liu@freescale.com> <1263456799-3306-3-git-send-email-yu.liu@freescale.com> <1263456799-3306-4-git-send-email-yu.liu@freescale.com> <BC00E67D-5906-4740-A961-84FC1C524A4F@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <linuxppc-dev@lists.ozlabs.org>,
	<netdev@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:64655 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab0AOCtm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 21:49:42 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o0F2nfSl011278
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 19:49:41 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id o0F2nhbO013466
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2010 20:49:44 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <BC00E67D-5906-4740-A961-84FC1C524A4F@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Kumar Gala [mailto:galak@kernel.crashing.org] 
> Sent: Friday, January 15, 2010 12:20 AM
> To: Liu Yu-B13201
> Cc: davem@davemloft.net; linuxppc-dev@lists.ozlabs.org; 
> netdev@vger.kernel.org
> Subject: Re: [PATCH 4/4] phy: add RTBI mode for m88e1111
> 
> 
> On Jan 14, 2010, at 2:13 AM, Liu Yu wrote:
> 
> > Signed-off-by: Liu Yu <yu.liu@freescale.com>
> > ---
> > drivers/net/phy/marvell.c |   38 
> ++++++++++++++++++++++++++++++++++++++
> > 1 files changed, 38 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> > index 6f69b9b..65ed385 100644
> > --- a/drivers/net/phy/marvell.c
> > +++ b/drivers/net/phy/marvell.c
> > @@ -63,6 +63,7 @@
> > #define MII_M1111_HWCFG_MODE_COPPER_RGMII	0xb
> > #define MII_M1111_HWCFG_MODE_FIBER_RGMII	0x3
> > #define MII_M1111_HWCFG_MODE_SGMII_NO_CLK	0x4
> > +#define MII_M1111_HWCFG_MODE_COPPER_RTBI	0x9
> > #define MII_M1111_HWCFG_FIBER_COPPER_AUTO	0x8000
> > #define MII_M1111_HWCFG_FIBER_COPPER_RES	0x2000
> > 
> > @@ -269,6 +270,43 @@ static int m88e1111_config_init(struct 
> phy_device *phydev)
> > 			return err;
> > 	}
> > 
> > +	if (phydev->interface == PHY_INTERFACE_MODE_RTBI) {
> > +		temp = phy_read(phydev, MII_M1111_PHY_EXT_CR);
> > +		if (temp < 0)
> > +			return temp;
> > +		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
> > +		err = phy_write(phydev, MII_M1111_PHY_EXT_CR, temp);
> > +		if (err < 0)
> > +			return err;
> > +
> > +		temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
> > +		if (temp < 0)
> > +			return temp;
> > +		temp &= ~(MII_M1111_HWCFG_MODE_MASK | 
> MII_M1111_HWCFG_FIBER_COPPER_RES);
> > +		temp |= 0x7 | MII_M1111_HWCFG_FIBER_COPPER_AUTO;
> 
> Does this magic 0x7 have some meaning?
> 

Hrr...  it's GMII to fibre mode.
Document 88E1111_erata_RevB2  chapter 4.35 describ the reason.
Without this sometimes phys couldnot work.
