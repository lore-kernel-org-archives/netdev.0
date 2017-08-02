From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v3 01/11] net: phy: Add rockchip phy driver support
Date: Wed, 2 Aug 2017 08:20:27 +0200
Message-ID: <20170802062027.GA18196@Red>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
 <1501654546-17292-2-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de, huangtao@rock-chips.com,
        hwg@rock-chips.com, alexandre.torgue@st.com,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
        peppe.cavallaro@st.com, linux-arm-kernel@lists.infradead.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501654546-17292-2-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello I have some minor comment below

> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/mii.h>
> +#include <linux/ethtool.h>
> +#include <linux/phy.h>
> +#include <linux/netdevice.h>

in alphabetic order please

[...]
> +static int rockchip_init_tstmode(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	/* Enable access to Analog and DSP register banks */
> +	ret = phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0400);
> +	if (ret)
> +		return ret;
> +
> +	ret = phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0000);
> +	if (ret)
> +		return ret;
> +
> +	return phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0400);
> +}
> +
> +static int rockchip_close_tstmode(struct phy_device *phydev)
> +{
> +	/* Back to basic register bank */
> +	return phy_write(phydev, SMI_ADDR_TSTCNTL, 0x0000);

The reuse of 0x0000 and 0x0400 seems to promote a define use

[...]
> +static struct phy_driver rockchip_phy_driver[] = {
> +{
> +	.phy_id			= 0x1234d400,
> +	.phy_id_mask		= 0xfffffff0,
> +	.name			= "Rockchip internal EPHY",
> +	.features		= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> +				   | SUPPORTED_Asym_Pause),
> +	.flags			= PHY_IS_INTERNAL,
> +	.link_change_notify	= rockchip_link_change_notify,
> +	.soft_reset		= genphy_soft_reset,
> +	.config_init		= rockchip_internal_phy_config_init,
> +	.config_aneg		= rockchip_config_aneg,
> +	.read_status		= genphy_read_status,
> +	.suspend		= genphy_suspend,
> +	.resume			= rockchip_phy_resume,
> +},
> +};
> +
> +module_phy_driver(rockchip_phy_driver);
> +
> +static struct mdio_device_id __maybe_unused rockchip_phy_tbl[] = {
> +	{ 0x1234d400, 0xfffffff0 },

Same comment for phy_id, use a define

Regards
Corentin Labbe
