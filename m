From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net-next v2] bindings: net: stmmac: add missing note about
 LPI interrupt
Date: Tue, 11 Apr 2017 08:08:35 +0200
Message-ID: <3a2ab310-adc7-ad66-4094-13e2125734f2@st.com>
References: <20170410074320.9506-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Niklas Cassel <niklass@axis.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Thierry Reding <treding@nvidia.com>,
        Eric Engestrom <eric@engestrom.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410074320.9506-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas

On 4/10/2017 9:43 AM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> The hardware has a LPI interrupt.
> There is already code in the stmmac driver to parse and handle the
> interrupt. However, this information was missing from the DT binding.

i wonder if we could improve the comments in this patch too
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---
>   Documentation/devicetree/bindings/net/stmmac.txt | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index f652b0c384ce..84e4cbfd3b0f 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -8,8 +8,8 @@ Required properties:
>     that services interrupts for this device
>   - interrupts: Should contain the STMMAC interrupts
>   - interrupt-names: Should contain the interrupt names "macirq"
> -  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> -  property
> +  "eth_wake_irq" if this interrupt is supported in the "interrupts" property
this is the PMT interrupt to manage the remote wake-up packet detection
> +  "eth_lpi" if this interrupt is supported in the "interrupts" property
This is the interrupt that occurs when Tx or Rx enter/exit from LPI state

Regards
Peppe
>   - phy-mode: See ethernet.txt file in the same directory.
>   - snps,reset-gpio 	gpio number for phy reset.
>   - snps,reset-active-low boolean flag to indicate if phy reset is active low.
> @@ -152,8 +152,8 @@ Examples:
>   		compatible = "st,spear600-gmac";
>   		reg = <0xe0800000 0x8000>;
>   		interrupt-parent = <&vic1>;
> -		interrupts = <24 23>;
> -		interrupt-names = "macirq", "eth_wake_irq";
> +		interrupts = <24 23 22>;
> +		interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
>   		mac-address = [000000000000]; /* Filled in by U-Boot */
>   		max-frame-size = <3800>;
>   		phy-mode = "gmii";
