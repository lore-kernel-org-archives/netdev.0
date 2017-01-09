From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH RFC 3/4] dt-bindings: correct marvell orion MDIO binding
 document
Date: Mon, 9 Jan 2017 10:31:56 +0000
Message-ID: <20170109103156.GA2147@leverpostej>
References: <20170107112656.GL14217@n2100.armlinux.org.uk>
 <E1cPpAk-0005uJ-TM@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <E1cPpAk-0005uJ-TM@rmk-PC.armlinux.org.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 07, 2017 at 11:28:30AM +0000, Russell King wrote:
> Correct the Marvell Orion MDIO binding document to properly reflect the
> cases where an interrupt is present.  Augment the examples to show this.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

This looks fine to me.

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

> ---
>  .../devicetree/bindings/net/marvell-orion-mdio.txt      | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
> index 9417e54c26c0..ca733ff68ab9 100644
> --- a/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
> +++ b/Documentation/devicetree/bindings/net/marvell-orion-mdio.txt
> @@ -7,7 +7,10 @@ interface.
>  
>  Required properties:
>  - compatible: "marvell,orion-mdio"
> -- reg: address and length of the SMI register
> +- reg: address and length of the MDIO registers.  When an interrupt is
> +  not present, the length is the size of the SMI register (4 bytes)
> +  otherwise it must be 0x84 bytes to cover the interrupt control
> +  registers.
>  
>  Optional properties:
>  - interrupts: interrupt line number for the SMI error/done interrupt
> @@ -17,7 +20,7 @@ The child nodes of the MDIO driver are the individual PHY devices
>  connected to this MDIO bus. They must have a "reg" property given the
>  PHY address on the MDIO bus.
>  
> -Example at the SoC level:
> +Example at the SoC level without an interrupt property:
>  
>  mdio {
>  	#address-cells = <1>;
> @@ -26,6 +29,16 @@ mdio {
>  	reg = <0xd0072004 0x4>;
>  };
>  
> +Example with an interrupt property:
> +
> +mdio {
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +	compatible = "marvell,orion-mdio";
> +	reg = <0xd0072004 0x84>;
> +	interrupts = <30>;
> +};
> +
>  And at the board level:
>  
>  mdio {
> -- 
> 2.7.4
> 
