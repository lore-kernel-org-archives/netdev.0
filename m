From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH net-next v3] bindings: net: stmmac: add missing note about
 LPI interrupt
Date: Wed, 19 Apr 2017 16:22:10 +0100
Message-ID: <d721ecfb-0c65-d654-3f36-75083d8c058a@synopsys.com>
References: <20170418123955.21335-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Niklas Cassel <niklass@axis.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Thierry Reding <treding@nvidia.com>,
        Eric Engestrom <eric@engestrom.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170418123955.21335-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

Às 1:39 PM de 4/18/2017, Niklas Cassel escreveu:
> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> The hardware has a LPI interrupt.
> There is already code in the stmmac driver to parse and handle the
> interrupt. However, this information was missing from the DT binding.
> 
> At the same time, improve the description of the existing interrupts.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index f652b0c384ce..c3a7be6615c5 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -7,9 +7,12 @@ Required properties:
>  - interrupt-parent: Should be the phandle for the interrupt controller
>    that services interrupts for this device
>  - interrupts: Should contain the STMMAC interrupts
> -- interrupt-names: Should contain the interrupt names "macirq"
> -  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> -  property
> +- interrupt-names: Should contain a list of interrupt names corresponding to
> +	the interrupts in the interrupts property, if available.
> +	Valid interrupt names are:
> +  - "macirq" (combined signal for various interrupt events)
> +  - "eth_wake_irq" (the interrupt to manage the remote wake-up packet detection)
> +  - "eth_lpi" (the interrupt that occurs when Tx or Rx enters/exits LPI state)
>  - phy-mode: See ethernet.txt file in the same directory.
>  - snps,reset-gpio 	gpio number for phy reset.
>  - snps,reset-active-low boolean flag to indicate if phy reset is active low.
> @@ -152,8 +155,8 @@ Examples:
>  		compatible = "st,spear600-gmac";
>  		reg = <0xe0800000 0x8000>;
>  		interrupt-parent = <&vic1>;
> -		interrupts = <24 23>;
> -		interrupt-names = "macirq", "eth_wake_irq";
> +		interrupts = <24 23 22>;
> +		interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
>  		mac-address = [000000000000]; /* Filled in by U-Boot */
>  		max-frame-size = <3800>;
>  		phy-mode = "gmii";
> 

Acked-By: Joao Pinto <jpinto@synopsys.com>

Regards!
