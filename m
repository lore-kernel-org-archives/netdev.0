From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next 2/2] net: hns: enet specisies a reference to
 dsaf (config and documents)
Date: Mon, 7 Dec 2015 08:12:21 -0600
Message-ID: <20151207141221.GA18040@rob-hp-laptop>
References: <1449302356-54658-1-git-send-email-yankejian@huawei.com>
 <1449302356-54658-3-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, arnd@arndb.de, fengguang.wu@intel.com,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	catalin.marinas@arm.com, will.deacon@arm.com,
	salil.mehta@huawei.com, Yisen.Zhuang@huawei.com,
	liguozhu@huawei.com, lisheng011@huawei.com,
	huangdaode@hisilicon.com, xuwei5@hisilicon.com,
	haifeng.wei@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linuxarm@huawei.com
To: yankejian <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:36014 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932410AbbLGOM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 09:12:28 -0500
Content-Disposition: inline
In-Reply-To: <1449302356-54658-3-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 05, 2015 at 03:59:16PM +0800, yankejian wrote:
> when enet specisies a reference to dsaf, the correlative config and

s/when/When/

> documents needs to update. this patch updates the correlative dtsi file

s/this/This/

> and bindings documents .
                        ^
extra space

This change breaks compatibility with old dtbs. IIRC, this is all new, 
so maybe it doesn't matter, but you should be explicit that you are 
doing that.


> 
> Signed-off-by: yankejian <yankejian@huawei.com>
> ---
>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
>  .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 +++++++++----------
>  3 files changed, 14 insertions(+), 17 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
> index 80411b2..ecacfa4 100644
> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
> @@ -4,8 +4,6 @@ Required properties:
>  - compatible: should be "hisilicon,hns-dsaf-v1" or "hisilicon,hns-dsaf-v2".
>    "hisilicon,hns-dsaf-v1" is for hip05.
>    "hisilicon,hns-dsaf-v2" is for Hi1610 and Hi1612.
> -- dsa-name: dsa fabric name who provide this interface.
> -  should be "dsafX", X is the dsaf id.
>  - mode: dsa fabric mode string. only support one of dsaf modes like these:
>  		"2port-64vf",
>  		"6port-16rss",
> @@ -26,9 +24,8 @@ Required properties:
>  
>  Example:
>  
> -dsa: dsa@c7000000 {
> +dsaf0: dsa@c7000000 {
>  	compatible = "hisilicon,hns-dsaf-v1";
> -	dsa_name = "dsaf0";
>  	mode = "6port-16rss";
>  	interrupt-parent = <&mbigen_dsa>;
>  	reg = <0x0 0xC0000000 0x0 0x420000
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
> index 41d19be..e6a9d1c 100644
> --- a/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hns-nic.txt
> @@ -4,8 +4,9 @@ Required properties:
>  - compatible: "hisilicon,hns-nic-v1" or "hisilicon,hns-nic-v2".
>    "hisilicon,hns-nic-v1" is for hip05.
>    "hisilicon,hns-nic-v2" is for Hi1610 and Hi1612.
> -- ae-name: accelerator name who provides this interface,
> -  is simply a name referring to the name of name in the accelerator node.
> +- ae-handle: accelerator engine handle for hns,
> +  specifies a reference to the associating hardware driver node.
> +  see Documentation/devicetree/bindings/net/hisilicon-hns-dsaf.txt
>  - port-id: is the index of port provided by DSAF (the accelerator). DSAF can
>    connect to 8 PHYs. Port 0 to 1 are both used for adminstration purpose. They
>    are called debug ports.
> @@ -41,7 +42,7 @@ Example:
>  
>  	ethernet@0{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <0>;
>  		local-mac-address = [a2 14 e4 4b 56 76];
>  	};
> diff --git a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
> index 606dd5a..89c883e 100644
> --- a/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
> +++ b/arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi
> @@ -23,9 +23,8 @@ soc0: soc@000000000 {
>  		};
>  	};
>  
> -	dsa: dsa@c7000000 {
> +	dsaf0: dsa@c7000000 {
>  		compatible = "hisilicon,hns-dsaf-v1";
> -		dsa_name = "dsaf0";
>  		mode = "6port-16rss";
>  		interrupt-parent = <&mbigen_dsa>;
>  
> @@ -127,7 +126,7 @@ soc0: soc@000000000 {
>  
>  	eth0: ethernet@0{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <0>;
>  		local-mac-address = [00 00 00 01 00 58];
>  		status = "disabled";
> @@ -135,14 +134,14 @@ soc0: soc@000000000 {
>  	};
>  	eth1: ethernet@1{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <1>;
>  		status = "disabled";
>  		dma-coherent;
>  	};
>  	eth2: ethernet@2{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <2>;
>  		local-mac-address = [00 00 00 01 00 5a];
>  		status = "disabled";
> @@ -150,7 +149,7 @@ soc0: soc@000000000 {
>  	};
>  	eth3: ethernet@3{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <3>;
>  		local-mac-address = [00 00 00 01 00 5b];
>  		status = "disabled";
> @@ -158,7 +157,7 @@ soc0: soc@000000000 {
>  	};
>  	eth4: ethernet@4{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <4>;
>  		local-mac-address = [00 00 00 01 00 5c];
>  		status = "disabled";
> @@ -166,7 +165,7 @@ soc0: soc@000000000 {
>  	};
>  	eth5: ethernet@5{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <5>;
>  		local-mac-address = [00 00 00 01 00 5d];
>  		status = "disabled";
> @@ -174,7 +173,7 @@ soc0: soc@000000000 {
>  	};
>  	eth6: ethernet@6{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <6>;
>  		local-mac-address = [00 00 00 01 00 5e];
>  		status = "disabled";
> @@ -182,7 +181,7 @@ soc0: soc@000000000 {
>  	};
>  	eth7: ethernet@7{
>  		compatible = "hisilicon,hns-nic-v1";
> -		ae-name = "dsaf0";
> +		ae-handle = <&dsaf0>;
>  		port-id = <7>;
>  		local-mac-address = [00 00 00 01 00 5f];
>  		status = "disabled";
> -- 
> 1.9.1
> 
