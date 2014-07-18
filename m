From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v3 1/2] ARM: at91/dt: describe rgmii ethernet phy connected
 to sama5d3xek boards
Date: Fri, 18 Jul 2014 16:21:36 +0200
Message-ID: <53C92D70.6050604@atmel.com>
References: <1405022394-8311-1-git-send-email-boris.brezillon@free-electrons.com> <1405022394-8311-2-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Boris BREZILLON <boris.brezillon@free-electrons.com>,
	"Jean-Christophe Plagniol-Villard" <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, "Rob Herring" <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	"Kumar Gala" <galak@codeaurora.org>, <devicetree@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405022394-8311-2-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2014 21:59, Boris BREZILLON :
> Add ethernet-phy nodes and specify phy interrupt (connected to pin PB25)
> and board specific timing configs.
> 
> Atmel has two different HW designs for its CPU modules: the first one
> (produced by Embest) is connecting PHYAD[0-2] pins to pull up resistors
> and the other one (produced by Ronetix) is connecting PHYAD0 to a pull up
> resistor and PHYAD[1-2] to pull down resistors.
> As a result, Ronetix design will have its PHY available at address 0x1 and
> Embest design at 0x7.
> By defining both phys we're letting the phy core detect the one actually
> available on the MDIO bus.
> 
> Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>
> ---
> 
> Florian, I dropped your Reviewed-by tag because this patch has slightly
> changed.

Hi Florian,

I would like to have your Ack on this one as we discussed this solution
with you.

Thanks, bye,


>  arch/arm/boot/dts/sama5d3xcm.dtsi | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/sama5d3xcm.dtsi b/arch/arm/boot/dts/sama5d3xcm.dtsi
> index b0b1331..755369e 100644
> --- a/arch/arm/boot/dts/sama5d3xcm.dtsi
> +++ b/arch/arm/boot/dts/sama5d3xcm.dtsi
> @@ -34,6 +34,36 @@
>  
>  			macb0: ethernet@f0028000 {
>  				phy-mode = "rgmii";
> +				#address-cells = <1>;
> +				#size-cells = <0>;
> +
> +				ethernet-phy@1 {
> +					reg = <0x1>;
> +					interrupt-parent = <&pioB>;
> +					interrupts = <25 IRQ_TYPE_EDGE_FALLING>;
> +					txen-skew-ps = <800>;
> +					txc-skew-ps = <3000>;
> +					rxdv-skew-ps = <400>;
> +					rxc-skew-ps = <3000>;
> +					rxd0-skew-ps = <400>;
> +					rxd1-skew-ps = <400>;
> +					rxd2-skew-ps = <400>;
> +					rxd3-skew-ps = <400>;
> +				};
> +
> +				ethernet-phy@7 {
> +					reg = <0x7>;
> +					interrupt-parent = <&pioB>;
> +					interrupts = <25 IRQ_TYPE_EDGE_FALLING>;
> +					txen-skew-ps = <800>;
> +					txc-skew-ps = <3000>;
> +					rxdv-skew-ps = <400>;
> +					rxc-skew-ps = <3000>;
> +					rxd0-skew-ps = <400>;
> +					rxd1-skew-ps = <400>;
> +					rxd2-skew-ps = <400>;
> +					rxd3-skew-ps = <400>;
> +				};
>  			};
>  
>  			pmc: pmc@fffffc00 {
> 


-- 
Nicolas Ferre
