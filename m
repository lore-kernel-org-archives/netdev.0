From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko@sntech.de>
Subject: Re: [PATCH 3/4] ARM: dts: Add emac nodes to the rk3188 device tree
Date: Thu, 04 Sep 2014 14:11:51 +0200
Message-ID: <2772929.YUnUK3Vc00@diego>
References: <1409763165-16461-1-git-send-email-romain.perier@gmail.com> <1409763165-16461-3-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gloria.sntech.de ([95.129.55.99]:39688 "EHLO gloria.sntech.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774AbaIDMJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 08:09:47 -0400
In-Reply-To: <1409763165-16461-3-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 3. September 2014, 16:52:44 schrieb Romain Perier:
> This adds support for EMAC Rockchip driver on RK3188 SoCs.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>

could you think about changing patches 3 and 4 with the diff below?

For one the comment style is not really following the coding style.
I guess either remove the comments completely or switch to a /* ... */
form.

More importantly, I think the compatible is a property of the SoC and does
not need to be replicated into every board, so it should live in a small
&emac node in the rk3188.dtsi to adapt the property.


Heiko


diff --git a/arch/arm/boot/dts/rk3188-radxarock.dts b/arch/arm/boot/dts/rk3188-radxarock.dts
index 9f37c6f..a5c90e1 100644
--- a/arch/arm/boot/dts/rk3188-radxarock.dts
+++ b/arch/arm/boot/dts/rk3188-radxarock.dts
@@ -100,7 +100,6 @@
 
 &emac {
 	status = "okay";
-	compatible = "rockchip,rk3188-emac";
 
 	pinctrl-names = "default";
 	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&phy_int>;
diff --git a/arch/arm/boot/dts/rk3188.dtsi b/arch/arm/boot/dts/rk3188.dtsi
index 1261358..fd7511e 100644
--- a/arch/arm/boot/dts/rk3188.dtsi
+++ b/arch/arm/boot/dts/rk3188.dtsi
@@ -193,14 +193,14 @@
 
 		emac {
 			emac_xfer: emac-xfer {
-				rockchip,pins = <RK_GPIO3 16 RK_FUNC_2 &pcfg_pull_none>, //tx_en
-						<RK_GPIO3 17 RK_FUNC_2 &pcfg_pull_none>, //txd1
-						<RK_GPIO3 18 RK_FUNC_2 &pcfg_pull_none>, //txd0
-						<RK_GPIO3 19 RK_FUNC_2 &pcfg_pull_none>, //rxd0
-						<RK_GPIO3 20 RK_FUNC_2 &pcfg_pull_none>, //rxd1
-						<RK_GPIO3 21 RK_FUNC_2 &pcfg_pull_none>, //mac_clk
-						<RK_GPIO3 22 RK_FUNC_2 &pcfg_pull_none>, //rx_err
-						<RK_GPIO3 23 RK_FUNC_2 &pcfg_pull_none>; //crs_dvalid
+				rockchip,pins = <RK_GPIO3 16 RK_FUNC_2 &pcfg_pull_none>, /* tx_en */
+						<RK_GPIO3 17 RK_FUNC_2 &pcfg_pull_none>, /* txd1 */
+						<RK_GPIO3 18 RK_FUNC_2 &pcfg_pull_none>, /* txd0 */
+						<RK_GPIO3 19 RK_FUNC_2 &pcfg_pull_none>, /* rxd0 */
+						<RK_GPIO3 20 RK_FUNC_2 &pcfg_pull_none>, /* rxd1 */
+						<RK_GPIO3 21 RK_FUNC_2 &pcfg_pull_none>, /* mac_clk */
+						<RK_GPIO3 22 RK_FUNC_2 &pcfg_pull_none>, /* rx_err */
+						<RK_GPIO3 23 RK_FUNC_2 &pcfg_pull_none>; /* crs_dvalid */
 			};
 
 			emac_mdio: emac-mdio {
@@ -385,6 +385,10 @@
 	};
 };
 
+&emac {
+	compatible = "rockchip,rk3188-emac";
+};
+
 &global_timer {
 	interrupts = <GIC_PPI 11 0xf04>;
 };


> ---
>  arch/arm/boot/dts/rk3188.dtsi | 18 ++++++++++++++++++
>  arch/arm/boot/dts/rk3xxx.dtsi | 17 +++++++++++++++++
>  2 files changed, 35 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/rk3188.dtsi b/arch/arm/boot/dts/rk3188.dtsi
> index ee801a9..a182713 100644
> --- a/arch/arm/boot/dts/rk3188.dtsi
> +++ b/arch/arm/boot/dts/rk3188.dtsi
> @@ -147,6 +147,24 @@
>  			bias-disable;
>  		};
> 
> +		emac {
> +			emac_xfer: emac-xfer {
> +				rockchip,pins = <RK_GPIO3 16 RK_FUNC_2 &pcfg_pull_none>, //tx_en
> +						<RK_GPIO3 17 RK_FUNC_2 &pcfg_pull_none>, //txd1
> +						<RK_GPIO3 18 RK_FUNC_2 &pcfg_pull_none>, //txd0
> +						<RK_GPIO3 19 RK_FUNC_2 &pcfg_pull_none>, //rxd0
> +						<RK_GPIO3 20 RK_FUNC_2 &pcfg_pull_none>, //rxd1
> +						<RK_GPIO3 21 RK_FUNC_2 &pcfg_pull_none>, //mac_clk
> +						<RK_GPIO3 22 RK_FUNC_2 &pcfg_pull_none>, //rx_err
> +						<RK_GPIO3 23 RK_FUNC_2 &pcfg_pull_none>; //crs_dvalid
> +			};
> +
> +			emac_mdio: emac-mdio {
> +				rockchip,pins = <RK_GPIO3 24 RK_FUNC_2 &pcfg_pull_none>,
> +						<RK_GPIO3 25 RK_FUNC_2 &pcfg_pull_none>;
> +			};
> +		};
> +
>  		i2c0 {
>  			i2c0_xfer: i2c0-xfer {
>  				rockchip,pins = <RK_GPIO1 24 RK_FUNC_1 &pcfg_pull_none>,
> diff --git a/arch/arm/boot/dts/rk3xxx.dtsi b/arch/arm/boot/dts/rk3xxx.dtsi
> index 8caf85d..208b1df 100644
> --- a/arch/arm/boot/dts/rk3xxx.dtsi
> +++ b/arch/arm/boot/dts/rk3xxx.dtsi
> @@ -91,6 +91,23 @@
>  		status = "disabled";
>  	};
> 
> +	emac: ethernet@10204000 {
> +		compatible = "snps,arc-emac";
> +		reg = <0x10204000 0x3c>;
> +		interrupts = <GIC_SPI 19 IRQ_TYPE_LEVEL_HIGH>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		rockchip,grf = <&grf>;
> +
> +		clocks = <&cru HCLK_EMAC>, <&cru SCLK_MAC>;
> +		clock-names = "hclk", "macref";
> +		max-speed = <100>;
> +		phy-mode = "rmii";
> +
> +		status = "disabled";
> +	};
> +
>  	mmc0: dwmmc@10214000 {
>  		compatible = "rockchip,rk2928-dw-mshc";
>  		reg = <0x10214000 0x1000>;
