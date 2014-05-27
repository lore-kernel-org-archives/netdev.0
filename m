From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/2] Documentation: add Device tree bindings for
 Hisilicon hix5hd2 ethernet
Date: Tue, 27 May 2014 14:34:23 +0100
Message-ID: <20140527133423.GB6969@leverpostej>
References: <1401194667-14445-1-git-send-email-zhangfei.gao@linaro.org>
 <1401194667-14445-2-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"haifeng.yan@linaro.org" <haifeng.yan@linaro.org>,
	"jchxue@gmail.com" <jchxue@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Zhangfei Gao <zhangfei.gao@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:49681 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752047AbaE0NfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 09:35:08 -0400
Content-Disposition: inline
In-Reply-To: <1401194667-14445-2-git-send-email-zhangfei.gao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2014 at 01:44:26PM +0100, Zhangfei Gao wrote:
> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
> ---
>  .../bindings/net/hisilicon-hix5hd2-gmac.txt        |   36 ++++++++++++++++++++
>  1 file changed, 36 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> new file mode 100644
> index 0000000..5fe3835
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt
> @@ -0,0 +1,36 @@
> +Hisilicon hix5hd2 gmac controller

Just to clarify, is the SoC name "hix5hd2", or is the 'x' a wildcard?

> +
> +Required properties:
> +- compatible: should be "hisilicon,hix5hd2-gmac".
> +- reg: specifies base physical address(s) and size of the device registers.
> +  The first region is the MAC register base and size.
> +  The second region is external interface control register.

Single registers? Are these not part of a larger block?

> +- interrupts: should contain the MAC interrupts

How many, in which order?

> +- #address-cells: must be <1>.
> +- #size-cells: must be <0>.
> +- phy-mode: see ethernet.txt [1].
> +- phy-handle: see ethernet.txt [1].
> +- mac-address: see ethernet.txt [1].
> +- clocks: clock phandle and specifier pair.

Is this the only clock input to the gmac block?

Is the clock input named in any documentation?

Cheers,
Mark.

> +
> +- PHY subnode: inherits from phy binding [2]
> +
> +[1] Documentation/devicetree/bindings/net/ethernet.txt
> +[2] Documentation/devicetree/bindings/net/phy.txt
> +
> +Example:
> +	gmac0: ethernet@f9840000 {
> +		compatible = "hisilicon,hix5hd2-gmac";
> +		reg = <0xf9840000 0x1000>,<0xf984300c 0x4>;
> +		interrupts = <0 71 4>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		phy-mode = "mii";
> +		phy-handle = <&phy2>;
> +		mac-address = [00 00 00 00 00 00];
> +		clocks = <&clock HIX5HD2_MAC0_CLK>;
> +
> +		phy2: ethernet-phy@2 {
> +			reg = <2>;
> +		};
> +	};
> -- 
> 1.7.9.5
> 
> 
