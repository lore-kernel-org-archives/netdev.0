From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 2/3] Documentation: add Device tree bindings for Hisilicon
 hix5hd2 ethernet
Date: Mon, 19 May 2014 20:26:18 +0400
Message-ID: <537A30AA.8080107@cogentembedded.com>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org> <1400504227-12047-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	haifeng.yan-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, jchxue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400504227-12047-3-git-send-email-zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/19/2014 04:57 PM, Zhangfei Gao wrote:

> Signed-off-by: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>   .../bindings/net/hisilicon-hix5hd2-net.txt         |   37 ++++++++++++++++++++
>   1 file changed, 37 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt

> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt
> new file mode 100644
> index 0000000..16b1f0e
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-net.txt
> @@ -0,0 +1,37 @@
> +Hisilicon hix5hd2 Ethernet Controller
> +
> +Required properties:
> +- compatible: should be "hisilicon,hix5hd2-mac".
> +- reg : Specifies base physical address(s) and size of the device registers.

    Er, I must note that the colon style here is not consistent with the rest 
of the properties, i.e. there's space before the colon here, while in other 
cases there's none.

> +  The first region is the mac register base and size.

    s/mac/MAC/.

> +  The second region is external interface control register.
> +- interrupts: Should contain the MAC interrupts
> +- #address-cells: Must be <1>.
> +- #size-cells: Must be <0>.

    Descriptions should consistently start with a lower case, I think...

> +- phy-mode: see ethernet.txt [1].
> +- phy-handle: see ethernet.txt [1].
> +- mac-address: see ethernet.txt [1].
> +- clocks: clock phandle and specifier pair.
> +
> +- phy subnode: inherits from phy binding [2]

    s/phy/PHY/.

> +
> +[1] Documentation/devicetree/bindings/net/ethernet.txt
> +[2] Documentation/devicetree/bindings/net/phy.txt
> +
> +Example:
> +	gmac0: ethernet@f9840000 {
> +		compatible = "hisilicon,hix5hd2-mac";
> +		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		phy-handle = <&phy0>;
> +		phy-mode = "mii";
> +		mac-address = [00 00 00 00 00 00];

    Don't think that's a good value, unless this is only a placeholder.

> +		interrupts = <0 71 4>;
> +		clocks = <&clock HIX5HD2_MAC0_CLK>;
> +
> +		phy0: ethernet-phy@2 {

    I'd rather label ut phy2...

> +			reg = <2>;
> +			compatible = "ethernet-phy-ieee802.3-c22";

    This is the default "compatible", i.e. there's no need to specify it, IIRC.

> +		};
> +	};

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
