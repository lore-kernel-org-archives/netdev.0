From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1.2] dt: emac: document device-tree based phy discovery
 and setup
Date: Mon, 27 Feb 2017 12:44:09 -0800
Message-ID: <cecba35f-0a94-67e8-543a-a1d340d62947@gmail.com>
References: <eaf5b812-deae-c5f7-3930-dadf0b0132bf@gmail.com>
 <0f6d91964359390ea08ff9d29f7d7c5ad49961c3.1488227767.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>, Andrew Lunn <andrew@lunn.ch>,
        Rob Herring <robh+dt@kernel.org>
To: Christian Lamparter <chunkeey@googlemail.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33328 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdB0UpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 15:45:11 -0500
In-Reply-To: <0f6d91964359390ea08ff9d29f7d7c5ad49961c3.1488227767.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2017 12:41 PM, Christian Lamparter wrote:
> This patch adds documentation for a new "phy-handle" property,
> "fixed-link" and "mdio" sub-node. These allows the enumeration
> of PHYs which are supported by the phy library under drivers/net/phy.
> 
> The EMAC ethernet controller in IBM and AMCC 4xx chips is
> currently stuck with a few privately defined phy
> implementations. It has no support for PHYs which
> are supported by the generic phylib.
> 
> Acked-by: Rob Herring <robh@kernel.org>
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
> ---
> Fixed: phy node - so it conforms to phy.txt.
> ---
> ---
>  .../devicetree/bindings/powerpc/4xx/emac.txt       | 61 +++++++++++++++++++++-
>  1 file changed, 59 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> index 712baf6c3e24..2fa861378294 100644
> --- a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> +++ b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
> @@ -71,6 +71,9 @@
>  			  For Axon it can be absent, though my current driver
>  			  doesn't handle phy-address yet so for now, keep
>  			  0x00ffffff in it.
> +    - phy-handle	: Used to describe configurations where a external PHY
> +			  is used. Please refer to:
> +			  Documentation/devicetree/bindings/net/ethernet.txt
>      - rx-fifo-size-gige : 1 cell, Rx fifo size in bytes for 1000 Mb/sec
>  			  operations (if absent the value is the same as
>  			  rx-fifo-size).  For Axon, either absent or 2048.
> @@ -81,8 +84,22 @@
>  			  offload, phandle of the TAH device node.
>      - tah-channel       : 1 cell, optional. If appropriate, channel used on the
>  			  TAH engine.
> +    - fixed-link	: Fixed-link subnode describing a link to a non-MDIO
> +			  managed entity. See
> +			  Documentation/devicetree/bindings/net/fixed-link.txt
> +			  for details.
> +    - mdio subnode	: When the EMAC has a phy connected to its local
> +			  mdio, which us supported by the kernel's network
> +			  PHY library in drivers/net/phy, there must be device
> +			  tree subnode with the following required properties:
> +				- #address-cells: Must be <1>.
> +				- #size-cells: Must be <0>.
>  
> -    Example:
> +			  For PHY definitions: Please refer to
> +			  Documentation/devicetree/bindings/net/phy.txt and
> +			  Documentation/devicetree/bindings/net/ethernet.txt
> +
> +    Examples:
>  
>  	EMAC0: ethernet@40000800 {
>  		device_type = "network";
> @@ -104,6 +121,47 @@
>  		zmii-channel = <0>;
>  	};
>  
> +	EMAC1: ethernet@ef600c00 {
> +		device_type = "network";
> +		compatible = "ibm,emac-apm821xx", "ibm,emac4sync";
> +		interrupt-parent = <&EMAC1>;
> +		interrupts = <0 1>;
> +		#interrupt-cells = <1>;
> +		#address-cells = <0>;
> +		#size-cells = <0>;
> +		interrupt-map = <0 &UIC2 0x10 IRQ_TYPE_LEVEL_HIGH /* Status */
> +				 1 &UIC2 0x14 IRQ_TYPE_LEVEL_HIGH /* Wake */>;
> +		reg = <0xef600c00 0x000000c4>;
> +		local-mac-address = [000000000000]; /* Filled in by U-Boot */
> +		mal-device = <&MAL0>;
> +		mal-tx-channel = <0>;
> +		mal-rx-channel = <0>;
> +		cell-index = <0>;
> +		max-frame-size = <9000>;
> +		rx-fifo-size = <16384>;
> +		tx-fifo-size = <2048>;
> +		fifo-entry-size = <10>;
> +		phy-mode = "rgmii";
> +		phy-handle = <&phy0>;
> +		phy-map = <0x00000000>;
> +		rgmii-device = <&RGMII0>;
> +		rgmii-channel = <0>;
> +		tah-device = <&TAH0>;
> +		tah-channel = <0>;
> +		has-inverted-stacr-oc;
> +		has-new-stacr-staopc;
> +
> +	        mdio {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +
> +			phy0: ethernet-phy@0 {
> +				compatible = "ethernet-phy-ieee802.3-c22";
> +				reg = <0>;

Missing closing curly brace here :) with that fixed:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
