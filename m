From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 1/4] net: hix5hd2_gmac: add generic compatible string
Date: Fri, 9 Dec 2016 16:35:21 -0600
Message-ID: <20161209223521.5dnj7l44e663sntl@rob-hp-laptop>
References: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
 <1480944481-118803-2-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, mturquette@baylibre.com,
        sboyd@codeaurora.org, linux@armlinux.org.uk,
        zhangfei.gao@linaro.org, yisen.zhuang@huawei.com,
        salil.mehta@huawei.com, davem@davemloft.net, arnd@arndb.de,
        andrew@lunn.ch, xuejiancheng@hisilicon.com,
        benjamin.chenhao@hisilicon.com, caizhiyong@hisilicon.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480944481-118803-2-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2016 at 09:27:58PM +0800, Dongpo Li wrote:
> The "hix5hd2" is SoC name, add the generic ethernet driver name.
> The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
> the SG/TXCSUM/TSO/UFO features.
> 
> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
> ---
>  .../devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt    |  9 +++++++--
>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c             | 15 +++++++++++----
>  2 files changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> index 75d398b..75920f0 100644
> --- a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> @@ -1,7 +1,12 @@
>  Hisilicon hix5hd2 gmac controller
>  
>  Required properties:
> -- compatible: should be "hisilicon,hix5hd2-gmac".
> +- compatible: should contain one of the following SoC strings:
> +	* "hisilicon,hix5hd2-gemac"
> +	* "hisilicon,hi3798cv200-gemac"
> +	and one of the following version string:
> +	* "hisilicon,hisi-gemac-v1"
> +	* "hisilicon,hisi-gemac-v2"

What combinations are valid? I assume both chips don't have both v1 and 
v2. 2 SoCs and 2 versions so far, I don't think there is much point to 
have the v1 and v2 compatible strings.

>  - reg: specifies base physical address(s) and size of the device registers.
>    The first region is the MAC register base and size.
>    The second region is external interface control register.
> @@ -20,7 +25,7 @@ Required properties:
>  
>  Example:
>  	gmac0: ethernet@f9840000 {
> -		compatible = "hisilicon,hix5hd2-gmac";
> +		compatible = "hisilicon,hix5hd2-gemac", "hisilicon,hisi-gemac-v1";

You can't just change compatible strings.

>  		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
>  		interrupts = <0 71 4>;
>  		#address-cells = <1>;
