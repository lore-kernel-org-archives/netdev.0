From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/3] phylib: add missing _{check_gmii_support,link_ok,nway_restart}
Date: Thu, 18 Sep 2008 14:20:45 +0200
Message-ID: <20080918122045.GA9157@xi.wantstofly.org>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org> <1220448012-20347-3-git-send-email-buytenh@wantstofly.org> <3661904F-A16E-4B85-8525-33F72257D1A3@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:41806 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbYIRMUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 08:20:49 -0400
Content-Disposition: inline
In-Reply-To: <3661904F-A16E-4B85-8525-33F72257D1A3@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 06:03:24PM -0500, Andy Fleming wrote:

> >drivers/net/mii.c provides a couple of routines which currently have
> >no phylib equivalents.  This patch provides those phylib equivalents.
> >
> >Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> I think all of this functionality is provided by other parts of the  
> phylib.  See below.
> 
> 
> >/**
> >+ * phy_check_gmii_support - check if the PHY supports (R)GMII
> >+ * @phydev: the phy_device struct
> >+ */
> >+int phy_check_gmii_support(struct phy_device *phydev)
> >+{
> >+	int retval;
> >+
> >+	retval = phy_read(phydev, MII_BMSR);
> >+	if (retval < 0 || (retval & BMSR_ESTATEN) == 0)
> >+		return 0;
> >+
> >+	retval = phy_read(phydev, MII_ESTATUS);
> >+	if (retval < 0)
> >+		return 0;
> >+
> >+	return !!(retval & (ESTATUS_1000_TFULL | ESTATUS_1000_THALF));
> >+}
> >+EXPORT_SYMBOL(phy_check_gmii_support);
> 
> If you look in genphy_config_init() in drivers/net/phy/phy_device.c,  
> you'll see that it fills in phydev->supported based on ESTATUS.  So  
> this function could be reduced to:
> 
> return !!(phydev->supported & (SUPPORTED_1000baseT_Full |  
> SUPPORTED_1000baseT_Half));

Right.  Actually, I can probably just replace the relevant code in
mv643xx_eth with:

	phy->advertising = phy->supported | ADVERTISED_Autoneg;
