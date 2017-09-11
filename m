From: Rob Herring <robh@kernel.org>
Subject: Re: [net-next PATCHv6 1/2] dt-bindings: net: Add DT bindings for
 Socionext Netsec
Date: Mon, 11 Sep 2017 15:37:38 -0500
Message-ID: <20170911203738.gco3nv2kynytkxuj@rob-hp-laptop>
References: <1504088657-6102-1-git-send-email-jaswinder.singh@linaro.org>
 <1504088752-6204-1-git-send-email-jaswinder.singh@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
        patches@linaro.org, arnd@arndb.de, mark.rutland@arm.com,
        andy@warmcat.com, Jassi Brar <jaswinder.singh@linaro.org>
To: Jassi Brar <jassisinghbrar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37854 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750987AbdIKUhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 16:37:40 -0400
Content-Disposition: inline
In-Reply-To: <1504088752-6204-1-git-send-email-jaswinder.singh@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 03:55:52PM +0530, Jassi Brar wrote:
> This patch adds documentation for Device-Tree bindings for the
> Socionext NetSec Controller driver.
> 
> Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
> ---
>  .../devicetree/bindings/net/socionext-netsec.txt   | 46 ++++++++++++++++++++++
>  1 file changed, 46 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/socionext-netsec.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/socionext-netsec.txt b/Documentation/devicetree/bindings/net/socionext-netsec.txt
> new file mode 100644
> index 0000000..12d596c
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/socionext-netsec.txt
> @@ -0,0 +1,46 @@
> +* Socionext NetSec Ethernet Controller IP
> +
> +Required properties:
> +- compatible: Should be "socionext,netsecv5"

This should be SoC specific, or also have an SoC specific string.

> +- reg: Address and length of the register sets, the first is the main
> +	registers, then the rdlar and tdlar regions for the SoC
> +- interrupts: Should contain ethernet controller interrupt
> +- clocks: phandle to any clocks to be switched by runtime_pm
> +- phy-mode: See ethernet.txt file in the same directory
> +- max-speed: See ethernet.txt file in the same directory
> +- max-frame-size: See ethernet.txt file in the same directory, if 9000 or
> +	above jumbo frames are enabled
> +- local-mac-address: See ethernet.txt file in the same directory
> +- phy-handle: phandle to select child phy
> +
> +Optional properties:
> +- use-jumbo: Boolean property to suggest if jumbo packets should be used or not

Is this common or vendor specific. The former should refer to a common 
doc. The latter should have a vendor prefix. I'd think the former makes 
sense here.

But then why do you need this and max-frame-size?

> +
> +For the child phy
> +
> +- compatible "ethernet-phy-ieee802.3-c22" is needed
> +- device_type "ethernet-phy"
> +- reg: phy address
> +
> +
> +Example:
> +	eth0: ethernet {
> +		compatible = "socionext,netsecv5";
> +		reg = <0 0x31600000 0x10000>, <0 0x31618000 0x4000>, <0 0x3161c000 0x4000>;
> +		interrupts = <0 163 0x4>;
> +		clocks = <&clk_alw_0_8>;
> +		phy-mode = "rgmii";
> +		max-speed = <1000>;
> +		max-frame-size = <9000>;
> +		local-mac-address = [ a4 17 31 00 00 ed ];
> +		phy-handle = <&ethphy0>;
> +
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		ethphy0: ethernet-phy@1 {
> +			device_type = "ethernet-phy";
> +			compatible = "ethernet-phy-ieee802.3-c22";
> +			reg = <1>;
> +		};
> +	};
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
