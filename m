From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: phy: Add error checks in the driver
Date: Fri, 19 Aug 2016 15:15:17 +0200
Message-ID: <20160819131517.GB7343@lunn.ch>
References: <1471610891-13353-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        appanad@xilinx.com, f.fainelli@gmail.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471610891-13353-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -	mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG, val);
> +	err = mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG,
> +			    val);
> +	if (err < 0)
> +		return err;
>  
>  	return 0;

Do you need to assign err? Why not just

   return mdiobus_write(phydev->mdio.bus, priv->addr, XILINX_GMII2RGMII_REG,
			val);
