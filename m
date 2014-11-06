From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Re: am335x: cpsw: phy ignores max-speed setting
Date: Thu, 6 Nov 2014 14:20:17 -0500
Message-ID: <20141106192017.GQ24110@csclub.uwaterloo.ca>
References: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, mpa@pengutronix.de,
	Daniel Mack <zonque@gmail.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.csclub.uwaterloo.ca ([129.97.134.52]:33549 "EHLO
	mail.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339AbaKFTUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:20:20 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2014 at 05:25:13PM +0100, Yegor Yefremov wrote:
> I' m trying to override max-speed setting for both CPSW connected
> PHYs. This is my DTS section for configuring CPSW:
> 
> &mac {
>         pinctrl-names = "default", "sleep";
>         pinctrl-0 = <&cpsw_default>;
>         pinctrl-1 = <&cpsw_sleep>;
>         dual_emac = <1>;
> 
>         status = "okay";
> };
> 
> &davinci_mdio {
>         pinctrl-names = "default", "sleep";
>         pinctrl-0 = <&davinci_mdio_default>;
>         pinctrl-1 = <&davinci_mdio_sleep>;
> 
>         status = "okay";
> };
> 
> &cpsw_emac0 {
>         phy_id = <&davinci_mdio>, <0>;
>         phy-mode = "rgmii-id";
>         dual_emac_res_vlan = <1>;
>         max-speed = <100>;
> };
> 
> &cpsw_emac1 {
>         phy_id = <&davinci_mdio>, <1>;
>         phy-mode = "rgmii-id";
>         dual_emac_res_vlan = <2>;
>         max-speed = <100>;
> };
> 
> But in drivers/net/phy/phy_device.c->of_set_phy_supported() routine I
> don't get through node check, i.e. node == NULL. Any idea why?
> 
> static void of_set_phy_supported(struct phy_device *phydev)
> {
>         struct device_node *node = phydev->dev.of_node;
>         u32 max_speed;

Did you try adding a printk here to make sure it is actually called?

>         if (!IS_ENABLED(CONFIG_OF_MDIO))
>                 return;

Do you have CONFIG_OF_MDIO on?  I would think so.

>         if (!node)
>                 return;
> 
>         if (!of_property_read_u32(node, "max-speed", &max_speed)) {
>                 /* The default values for phydev->supported are
> provided by the PHY
>                  * driver "features" member, we want to reset to sane
> defaults fist
>                  * before supporting higher speeds.
>                  */
>                 phydev->supported &= PHY_DEFAULT_FEATURES;
> 
>                 switch (max_speed) {
>                 default:
>                         return;
> 
>                 case SPEED_1000:
>                         phydev->supported |= PHY_1000BT_FEATURES;
>                 case SPEED_100:
>                         phydev->supported |= PHY_100BT_FEATURES;
>                 case SPEED_10:
>                         phydev->supported |= PHY_10BT_FEATURES;
>                 }
>         }
> }

-- 
Len Sorensen
