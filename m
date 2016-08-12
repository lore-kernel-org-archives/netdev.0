From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/4] net: hix5hd2_gmac: add tx scatter-gather feature
Date: Fri, 12 Aug 2016 13:43:37 -0500
Message-ID: <20160812184336.GA5706@rob-hp-laptop>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
 <1470906115-155569-2-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, mturquette@baylibre.com,
	sboyd@codeaurora.org, linux@armlinux.org.uk,
	zhangfei.gao@linaro.org, yisen.zhuang@huawei.com,
	salil.mehta@huawei.com, davem@davemloft.net, arnd@arndb.de,
	andrew@lunn.ch, xuejiancheng@hisilicon.com,
	benjamin.chenhao@hisilicon.com, howell.yang@hisilicon.com,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-clk-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470906115-155569-2-git-send-email-lidongpo@hisilicon.com>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2016 at 05:01:52PM +0800, Dongpo Li wrote:
> From: Li Dongpo <lidongpo@hisilicon.com>
> 
> The "hix5hd2" is SoC name, add the generic ethernet driver name.
> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
> the SG/TXCSUM/TSO/UFO features.
> This patch only adds the SG(scatter-gather) driver for transmitting,
> the drivers of other features will be submitted later.

The compatible string changes should probably be a separate patch.

> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
> ---
>  .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   9 +-
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 213 +++++++++++++++++++--
>  2 files changed, 205 insertions(+), 17 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> index 75d398b..3c02fac 100644
> --- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> @@ -1,7 +1,12 @@
>  Hisilicon hix5hd2 gmac controller
>  
>  Required properties:
> -- compatible: should be "hisilicon,hix5hd2-gmac".
> +- compatible: should contain one of the following version strings:
> +	* "hisilicon,hisi-gemac-v1"
> +	* "hisilicon,hisi-gemac-v2"
> +	and one of the following SoC string:
> +	* "hisilicon,hix5hd2-gemac"
> +	* "hisilicon,hi3798cv200-gemac"

Make it clear what the order should be.

2 SOC versions so far and 2 generic versions. I'm not really convinced 
that the generic string is needed.

>  - reg: specifies base physical address(s) and size of the device registers.
>    The first region is the MAC register base and size.
>    The second region is external interface control register.
> @@ -20,7 +25,7 @@ Required properties:
>  
>  Example:
>  	gmac0: ethernet@f9840000 {
> -		compatible = "hisilicon,hix5hd2-gmac";
> +		compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";
>  		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
>  		interrupts = <0 71 4>;
>  		#address-cells = <1>;
