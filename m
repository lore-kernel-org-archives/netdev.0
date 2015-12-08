From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 next 1/2] dts: hisi: fixes no syscon error when init
 mdio
Date: Tue, 8 Dec 2015 09:25:14 -0600
Message-ID: <20151208152514.GA27037@rob-hp-laptop>
References: <1449476707-224320-1-git-send-email-yankejian@huawei.com>
 <1449476707-224320-2-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	xuwei5@hisilicon.com, catalin.marinas@arm.com, will.deacon@arm.com,
	wangkefeng.wang@huawei.com, dingtianhong@huawei.com,
	liguozhu@huawei.com, Yisen.Zhuang@huawei.com, sboyd@codeaurora.org,
	haojian.zhuang@linaro.org, wangzhou1@hisilicon.com,
	bintian.wang@huawei.com, long.wanglong@huawei.com,
	leo.yan@linaro.org, haifeng.wei@huawei.com,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linuxarm@huawei.com
To: yankejian <yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449476707-224320-2-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 04:25:06PM +0800, yankejian wrote:
> Signed-nux start up, we get the log below:
> "Hi-HNS_MDIO 803c0000.mdio: no syscon hisilicon,peri-c-subctrl
>  mdio_bus mdio@803c0000: mdio sys ctl reg has not maped       "
> 
> the source code about the subctrl is dealled with syscon, but dts doesn't.

The source...

s/dealled/dealt/

> it cause such fault. so this patch adds the syscon info on dts files to
> fixes it. and it adds documentation for the devicetree bindings used by

Capitalization please.

> DT files of Hisilicon Hip05-D02 development board.
> 
> Signed-off-by: yankejian <yankejian@huawei.com>
> ---
> change log:
> v2:
>  1) updates the related documented in the binding as well
>  2) use the normal naming conventions using '-' instead of '_'
> 
> v1:
>  initial version
> ---
>  .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
>  arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
>  3 files changed, 23 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
> index 6ac7c00..9f05767 100644
> --- a/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
> +++ b/Documentation/devicetree/bindings/arm/hisilicon/hisilicon.txt
> @@ -187,6 +187,22 @@ Example:
>  		reg = <0xb0000000 0x10000>;
>  	};
>  
> +Hisilicon HiP05 PERISUB system controller
> +
> +Required properties:
> +- compatible : "hisilicon,peri-c-subctrl", "syscon";
> +- reg : Register address and size
> +
> +The HiP05 PERISUB system controller is shared by peripheral controllers in
> +HiP05 Soc to implement some basic configurations. the peripheral
> +controllers include mdio, ddr, iic, uart, timer and so on.
> +
> +Example:
> +	/* for HiP05 PCIe-SAS system */
> +	peri-c-subctrl: sub-ctrl-c@80000000 {

s/sub-ctrl-c/syscon/


> +		compatible = "hisilicon,peri-c-subctrl", "syscon";
> +		reg = <0x0 0x80000000 0x0 0x10000>;
> +	};
>  -----------------------------------------------------------------------
>  Hisilicon CPU controller
>  
> diff --git a/arch/arm64/boot/dts/hisilicon/hip05.dtsi b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
> index 4ff16d0..5fec740 100644
> --- a/arch/arm64/boot/dts/hisilicon/hip05.dtsi
> +++ b/arch/arm64/boot/dts/hisilicon/hip05.dtsi
> @@ -246,6 +246,11 @@
>  			clock-frequency = <200000000>;
>  		};
>  
> +		peri_c_subctrl: sub-ctrl-c@80000000 {
> +			compatible = "hisilicon,peri-c-subctrl", "syscon";
> +			reg = < 0x0 0x80000000 0x0 0x10000>;
> +		};
> +
>  		uart0: uart@80300000 {
>  			compatible = "snps,dw-apb-uart";
>  			reg = <0x0 0x80300000 0x0 0x10000>;
> diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
> index 606dd5a..da7b6e6 100644
> --- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
> +++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
> @@ -10,8 +10,8 @@ soc0: soc@000000000 {
>  		#address-cells = <1>;
>  		#size-cells = <0>;
>  		compatible = "hisilicon,hns-mdio";
> -		reg = <0x0 0x803c0000 0x0 0x10000
> -		       0x0 0x80000000 0x0 0x10000>;
> +		reg = <0x0 0x803c0000 0x0 0x10000>;
> +		subctrl-vbase = <&peri_c_subctrl>;
>  
>  		soc0_phy0: ethernet-phy@0 {
>  			reg = <0x0>;
> -- 
> 1.9.1
> 
