From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 1/4] Documentation: devicetree: add multiple cpu port DSA
 binding
Date: Wed, 4 Jan 2017 13:58:37 +0100
Message-ID: <20170104125837.GF10768@lunn.ch>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
 <1483515484-21793-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42871 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966905AbdADNkg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 08:40:36 -0500
Content-Disposition: inline
In-Reply-To: <1483515484-21793-2-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 08:38:01AM +0100, John Crispin wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> 
> Extend the DSA binding documentation, adding the new properties required
> when there is more than one CPU port attached to the switch.

Hi John

Thanks for picking up my old patches.

> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: devicetree@vger.kernel.org
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  Documentation/devicetree/bindings/net/dsa/dsa.txt |   67 ++++++++++++++++++++-
>  1 file changed, 66 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> index a4a570f..fc901cf 100644
> --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
> +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> @@ -337,13 +337,25 @@ Optional property:
>  			  This mii-bus will be used in preference to the
>  			  global dsa,mii-bus defined above, for this switch.
>  
> +- ethernet		: Optional for "cpu" ports. A phandle to an ethernet
> +                          device which will be used by this CPU port for
> +			  passing packets to/from the host. If not present,
> +			  the port will use the "dsa,ethernet" property
> +			  defined above.

This appears to be for the old binding. The new binding has this
already.  I only want to support multiple CPU ports with the new
binding, since Florian is in the process of removing the old one.

> +
> +- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
> +			  "cpu" port, which will be used for passing packets
> +			  from this port to the host. If not present, the first
> +			  "cpu" port will be used.
> +
> +
>  Optional subnodes:
>  - fixed-link		: Fixed-link subnode describing a link to a non-MDIO
>  			  managed entity. See
>  			  Documentation/devicetree/bindings/net/fixed-link.txt
>  			  for details.
>  
> -Example:
> +Examples:
>  
>  	dsa@0 {
>  		compatible = "marvell,dsa";
> @@ -416,3 +428,56 @@ Example:
>  			};
>  		};
>  	};
> +
> +	dsa@1 {
> +		compatible = "marvell,dsa";
> +		#address-cells = <2>;
> +		#size-cells = <0>;
> +
> +		dsa,ethernet = <&eth0port>;
> +		dsa,mii-bus = <&mdio>;
> +
> +		switch@0 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
> +
> +			port@0 {
> +				reg = <0>;
> +				label = "lan4";
> +			};
> +
> +			port@1 {
> +				reg = <1>;
> +				label = "lan3";
> +				cpu = <&cpu1>;
> +			};

Again, this is the old binding. The example should use the new
binding.

Thanks
	Andrew
