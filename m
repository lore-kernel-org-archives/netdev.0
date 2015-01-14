From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH RESEND v2] net: fec: fix MDIO bus assignement for dual
 fec SoC's
Date: Wed, 14 Jan 2015 00:27:30 -0500 (EST)
Message-ID: <20150114.002730.1449798194556067465.davem@davemloft.net>
References: <1421191221-23095-1-git-send-email-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	fugang.duan-KZfg59tc24xl57MIdRCFDg@public.gmane.org, fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org, LW-bxm8fMRDkQLDiMYJYoSAnRvVK+yQ3ZXh@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stefan-XLVq0VzYD2Y@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421191221-23095-1-git-send-email-stefan-XLVq0VzYD2Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefan Agner <stefan-XLVq0VzYD2Y@public.gmane.org>
Date: Wed, 14 Jan 2015 00:20:21 +0100

> On i.MX28, the MDIO bus is shared between the two FEC instances.
> The driver makes sure that the second FEC uses the MDIO bus of the
> first FEC. This is done conditionally if FEC_QUIRK_ENET_MAC is set.
> However, in newer designs, such as Vybrid or i.MX6SX, each FEC MAC
> has its own MDIO bus. Simply removing the quirk FEC_QUIRK_ENET_MAC
> is not an option since other logic, triggered by this quirk, is
> still needed.
> 
> Furthermore, there are board designs which use the same MDIO bus
> for both PHY's even though the second bus would be available on the
> SoC side. Such layout are popular since it saves pins on SoC side.
> Due to the above quirk, those boards currently do work fine. The
> boards in the mainline tree with such a layout are:
> - Freescale Vybrid Tower with TWR-SER2 (vf610-twr.dts)
> - Freescale i.MX6 SoloX SDB Board (imx6sx-sdb.dts)
> 
> This patch adds a new quirk FEC_QUIRK_SINGLE_MDIO for i.MX28, which
> makes sure that the MDIO bus of the first FEC is used in any case.
> 
> However, the boards above do have a SoC with a MDIO bus for each FEC
> instance. But the PHY's are not connected in a 1:1 configuration. A
> proper device tree description is needed to allow the driver to
> figure out where to find its PHY. This patch fixes that shortcoming
> by adding a MDIO bus child node to the first FEC instance, along
> with the two PHY's on that bus, and making use of the phy-handle
> property to add a reference to the PHY's.
> 
> Acked-by: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Signed-off-by: Stefan Agner <stefan-XLVq0VzYD2Y@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
