From: Matthias Brugger <matthias.bgg@gmail.com>
Subject: Re: [PATCH v1 5/6] dtb: xgene: Remove clock nodes
Date: Mon, 30 May 2016 09:34:00 +0200
Message-ID: <574BECE8.2050307@gmail.com>
References: <1464333768-26150-1-git-send-email-isubramanian@apm.com>
 <1464333768-26150-6-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: patches@apm.com, linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36596 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbcE3HeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 03:34:03 -0400
In-Reply-To: <1464333768-26150-6-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 27/05/16 09:22, Iyappan Subramanian wrote:
> Since the MDIO will be responsible for clock reset, removing the clock
> nodes from shadowcat xge0 and storm sgenet1.
>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Fushen Chen <fchen@apm.com>
> Tested-by: Toan Le <toanle@apm.com>
> ---
>   arch/arm64/boot/dts/apm/apm-shadowcat.dtsi | 12 ------------
>   arch/arm64/boot/dts/apm/apm-storm.dtsi     | 18 ++++--------------
>   2 files changed, 4 insertions(+), 26 deletions(-)
>
> diff --git a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
> index 8106957..f27563d 100644
> --- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
> +++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
> @@ -299,17 +299,6 @@
>   				clock-output-names = "pcie1clk";
>   			};
>
> -			xge0clk: xge0clk@1f61c000 {
> -				compatible = "apm,xgene-device-clock";
> -				#clock-cells = <1>;
> -				clocks = <&socplldiv2 0>;
> -				reg = <0x0 0x1f61c000 0x0 0x1000>;
> -				reg-names = "csr-reg";
> -				enable-mask = <0x3>;
> -				csr-mask = <0x3>;
> -				clock-output-names = "xge0clk";
> -			};
> -

mdio@0x1f610000 has xge0clk as input (patch 4), so deleting the node 
here will break the device tree. I suppose the mdio consumes the 
menetclk as in apm-storm.dtsi.

Regards,
Matthias

>   			xge1clk: xge1clk@1f62c000 {
>   				compatible = "apm,xgene-device-clock";
>   				#clock-cells = <1>;
> @@ -643,7 +632,6 @@
>   			interrupts = <0 96 4>,
>   				     <0 97 4>;
>   			dma-coherent;
> -			clocks = <&xge0clk 0>;
>   			local-mac-address = [00 01 73 00 00 01];
>   			phy-connection-type = "sgmii";
>   			phy-handle = <&sgenet0phy>;
> diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> index 18f694ea..f631fe4 100644
> --- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
> +++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> @@ -237,20 +237,11 @@
>   				clocks = <&socplldiv2 0>;
>   				reg = <0x0 0x1f21c000 0x0 0x1000>;
>   				reg-names = "csr-reg";
> -				csr-mask = <0x3>;
> +				csr-mask = <0xa>;
> +				enable-mask = <0xf>;
>   				clock-output-names = "sge0clk";
>   			};
>
> -			sge1clk: sge1clk@1f21c000 {
> -				compatible = "apm,xgene-device-clock";
> -				#clock-cells = <1>;
> -				clocks = <&socplldiv2 0>;
> -				reg = <0x0 0x1f21c000 0x0 0x1000>;
> -				reg-names = "csr-reg";
> -				csr-mask = <0xc>;
> -				clock-output-names = "sge1clk";
> -			};
> -
>   			xge0clk: xge0clk@1f61c000 {
>   				compatible = "apm,xgene-device-clock";
>   				#clock-cells = <1>;
> @@ -938,9 +929,9 @@
>   			reg-names = "enet_csr", "ring_csr", "ring_cmd";
>   			interrupts = <0x0 0x3c 0x4>;
>   			dma-coherent;
> -			clocks = <&menetclk 0>;
>   			/* mac address will be overwritten by the bootloader */
>   			local-mac-address = [00 00 00 00 00 00];
> +			clocks = <&menetclk 0>;
>   			phy-connection-type = "rgmii";
>   			phy-handle = <&menetphy>;
>   		};
> @@ -955,8 +946,8 @@
>   			interrupts = <0x0 0xA0 0x4>,
>   				     <0x0 0xA1 0x4>;
>   			dma-coherent;
> -			clocks = <&sge0clk 0>;
>   			local-mac-address = [00 00 00 00 00 00];
> +			clocks = <&sge0clk 0>;
>   			phy-connection-type = "sgmii";
>   			phy-handle = <&sgenet0phy>;
>   		};
> @@ -972,7 +963,6 @@
>   				     <0x0 0xAD 0x4>;
>   			port-id = <1>;
>   			dma-coherent;
> -			clocks = <&sge1clk 0>;
>   			local-mac-address = [00 00 00 00 00 00];
>   			phy-connection-type = "sgmii";
>   			phy-handle = <&sgenet1phy>;
>
