From: PERIER Romain <romain.perier@gmail.com>
Subject: Re: [PATCH v2 2/4] dt-bindings: Document EMAC Rockchip
Date: Wed, 3 Sep 2014 20:41:50 +0200
Message-ID: <CABgxDoJ9oFtDL9Wp-Lp3jBEXGidGeWeqYWUtxxfpQtf1V63BwA@mail.gmail.com>
References: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
	<1409763165-16461-2-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:41304 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbaICSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 14:41:54 -0400
Received: by mail-qa0-f47.google.com with SMTP id x12so8180766qac.6
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 11:41:51 -0700 (PDT)
In-Reply-To: <1409763165-16461-2-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

see "[PATCH v5 1/4] ethernet: arc: Add support for Rockchip SoC layer
device tree bindings" for acceptance

2014-09-03 18:52 GMT+02:00 Romain Perier <romain.perier@gmail.com>:
> This adds the necessary binding documentation for the EMAC Rockchip platform
> driver found in RK3066 and RK3188 SoCs.
>
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> ---
>  .../devicetree/bindings/net/emac_rockchip.txt      | 50 ++++++++++++++++++++++
>  1 file changed, 50 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/emac_rockchip.txt
>
> diff --git a/Documentation/devicetree/bindings/net/emac_rockchip.txt b/Documentation/devicetree/bindings/net/emac_rockchip.txt
> new file mode 100644
> index 0000000..8dc1c79
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/emac_rockchip.txt
> @@ -0,0 +1,50 @@
> +* ARC EMAC 10/100 Ethernet platform driver for Rockchip Rk3066/RK3188 SoCs
> +
> +Required properties:
> +- compatible: Should be "rockchip,rk3066-emac" or "rockchip,rk3188-emac"
> +  according to the target SoC.
> +- reg: Address and length of the register set for the device
> +- interrupts: Should contain the EMAC interrupts
> +- rockchip,grf: phandle to the syscon grf used to control speed and mode
> +  for emac.
> +- phy: see ethernet.txt file in the same directory.
> +- phy-mode: see ethernet.txt file in the same directory.
> +
> +Optional properties:
> +- phy-supply: phandle to a regulator if the PHY needs one
> +
> +Clock handling:
> +- clocks: Must contain an entry for each entry in clock-names.
> +- clock-names: Shall be "hclk" for the host clock needed to calculate and set
> +  polling period of EMAC and "macref" for the reference clock needed to transfer
> +  data to and from the phy.
> +
> +Child nodes of the driver are the individual PHY devices connected to the
> +MDIO bus. They must have a "reg" property given the PHY address on the MDIO bus.
> +
> +Examples:
> +
> +ethernet@10204000 {
> +       compatible = "rockchip,rk3188-emac";
> +       reg = <0xc0fc2000 0x3c>;
> +       interrupts = <6>;
> +       mac-address = [ 00 11 22 33 44 55 ];
> +
> +       clocks = <&cru HCLK_EMAC>, <&cru SCLK_MAC>;
> +       clock-names = "hclk", "macref";
> +
> +       pinctrl-names = "default";
> +       pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&phy_int>;
> +
> +       rockchip,grf = <&grf>;
> +
> +       phy = <&phy0>;
> +       phy-mode = "rmii";
> +       phy-supply = <&vcc_rmii>;
> +
> +       #address-cells = <1>;
> +       #size-cells = <0>;
> +       phy0: ethernet-phy@0 {
> +             reg = <1>;
> +       };
> +};
> --
> 1.9.1
>
