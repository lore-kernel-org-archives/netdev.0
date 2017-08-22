From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 3/4] net: phy: realtek: add disable RX
 internal delay mode
Date: Tue, 22 Aug 2017 15:39:06 +0200
Message-ID: <20170822133906.GG24555@lunn.ch>
References: <20170822040400.12166-1-icenowy@aosc.io>
 <20170822040400.12166-4-icenowy@aosc.io>
Reply-To: andrew-g2DYL2Zd6BY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Return-path: <linux-sunxi+bncBDJNHL5JSEOBBD7I6DGAKGQEFAA2BSQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170822040400.12166-4-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2017 at 12:03:59PM +0800, Icenowy Zheng wrote:
> From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
> 
> Some RTL8211E chips have broken GbE function, which needs a hack to
> fix. It's said that this fix will affect the performance on not-buggy
> PHYs, so it should only be enabled on boards with the broken PHY.

I would not call this a broken PHY. It is a question of board
design. If you have shorter tracks, you need a delay. If you have long
tracks, you don't. Hence the four RGMII modes, so you can select if
the delay is needed or not, depending on your board design.

> Currently only some Pine64+ boards are known to have this issue.

Design feature.

Please remove all reference to bug.
 
> This hack is said to disable RX relay for RTL8211E according to Realtek.
> So implement it as RGMII-TXID mode.

Do we know that the TX lines do have a delay after making this change?
We need to be careful here. We will get into a mess if this is
actually RGMII not RGMII_TXID, and somebody designs a board which
needs RGMII-TXID.

> +#include <linux/of.h>
>  #include <linux/phy.h>
>  #include <linux/module.h>

> +static int rtl8211e_config_init(struct phy_device *phydev)
> +{
> +	struct device *dev = &phydev->mdio.dev;
> +	struct device_node *of_node = dev->of_node;

You don't appear to use of_node, nor dev. Please remove, along with
the header file.

    Andrew
