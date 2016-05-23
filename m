From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC] NET: PHY: adds driver for Lantiq PHY11G
Date: Mon, 23 May 2016 14:04:00 +0200
Message-ID: <20160523120400.GB17916@lunn.ch>
References: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47866 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbcEWMEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 May 2016 08:04:04 -0400
Content-Disposition: inline
In-Reply-To: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int lantiq_gphy_config_init(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Mask all interrupts */
> +	err = phy_write(phydev, MII_VR9_11G_IMASK, 0);
> +	if (err)
> +		return err;
> +
> +	/* Clear all pending interrupts */
> +	phy_read(phydev, MII_VR9_11G_ISTAT);
> +
> +	phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, 0xc5);
> +	phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, 0x67);
> +	phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, 0x42);
> +	phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, 0x10);
> +	phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, 0x70);
> +	phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, 0x03);
> +	phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, 0x20);
> +	phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, 0x00);
> +	phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, 0x40);
> +	phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, 0x20);

Please could you use #define's rather than magic numbers. That helps
document what these writes are doing.

	 Thanks
		Andrew
