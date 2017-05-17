From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] drivers: net: xgene: Check all RGMII phy mode
 variants
Date: Wed, 17 May 2017 22:26:33 +0200
Message-ID: <20170517202633.GA14413@lunn.ch>
References: <1495051550-28961-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, f.fainelli@gmail.com,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Quan Nguyen <qnguyen@apm.com>
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34805 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751104AbdEQU0f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 16:26:35 -0400
Content-Disposition: inline
In-Reply-To: <1495051550-28961-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +bool is_xgene_enet_phy_mode_rgmii(struct net_device *ndev)
> +{
> +	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +	int phy_mode = pdata->phy_mode;
> +	bool ret;
> +
> +	ret = phy_mode == PHY_INTERFACE_MODE_RGMII ||
> +	      phy_mode == PHY_INTERFACE_MODE_RGMII_ID ||
> +	      phy_mode == PHY_INTERFACE_MODE_RGMII_RXID ||
> +	      phy_mode == PHY_INTERFACE_MODE_RGMII_TXID;
> +
> +	return ret;
> +}

include/linux/phy.h:

/**
 * phy_interface_is_rgmii - Convenience function for testing if a PHY interface
 * is RGMII (all variants)
 * @phydev: the phy_device struct
 */
static inline bool phy_interface_is_rgmii(struct phy_device *phydev)
{
        return phydev->interface >= PHY_INTERFACE_MODE_RGMII &&
                phydev->interface <= PHY_INTERFACE_MODE_RGMII_TXID;
};

	Andrew
