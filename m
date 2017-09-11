From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: Re: [PATCH net-next 1/3] dt-bindings: net: add DT bindings for Socionext UniPhier AVE
Date: Mon, 11 Sep 2017 16:11:51 +0900
Message-ID: <20170911161151.671C.4A936039@socionext.com>
References: <1504875731-3680-2-git-send-email-hayashi.kunihiko@socionext.com> <0d9fb986-ca31-0f86-122f-b2679faeb2f4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0d9fb986-ca31-0f86-122f-b2679faeb2f4@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Fri, 8 Sep 2017 11:54:31 -0700 <f.fainelli@gmail.com> wrote:

> On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
> > DT bindings for the AVE ethernet controller found on Socionext's
> > UniPhier platforms.
> > 
> > Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
> > Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
> > ---
> >  .../bindings/net/socionext,uniphier-ave4.txt       | 44 ++++++++++++++++++++++
> >  1 file changed, 44 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
> > new file mode 100644
> > index 0000000..57ae96d
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
> > @@ -0,0 +1,44 @@
> > +* Socionext AVE ethernet controller
> > +
> > +This describes the devicetree bindings for AVE ethernet controller
> > +implemented on Socionext UniPhier SoCs.
> > +
> > +Required properties:
> > + - compatible:  Should be "socionext,uniphier-ave4"
> > + - reg: Address where registers are mapped and size of region.
> > + - interrupts: IRQ common for mac and phy interrupts.
> > + - phy-mode: See ethernet.txt in the same directory.
> > + - #address-cells: Must be <1>.
> > + - #size-cells: Must be <0>.
> > + - Node, with 'reg' property, for each PHY on the MDIO bus.
> > +
> > +Optional properties:
> > + - socionext,desc-bits: 32/64 descriptor size. Default 32.
> 
> 32 bits, this has an unit. Why is this configurable through Device Tree
> and if this is describing the HW, as it should, why is not that inferred
> from the compatible string?

I've thought the common compatible string was reasonable for all UniPhier
SoCs. However, since there are some different features among SoCs
like "desc-bits" etc. and such feature would increase from now on,
it's convenient to add compatible strings for each SoCs.

> > + - local-mac-address: See ethernet.txt in the same directory.
> > + - pinctrl-names: List of assigned state names, see pinctrl
> > +	binding documentation.
> > + - pinctrl-0: List of phandles to configure the GPIO pin used
> > +	as interrupt line, see also generic and your platform
> > +	specific pinctrl binding documentation.
> > + - socionext,internal-phy-interrupt: Boolean to denote if the
> > +	PHY interrupt is internally handled by the MAC.
> 
> Interesting, why do you need to declare this as opposed to also
> determining this entirely from the compatible string of the Ethernet MAC?

This property was added after determining to use common compatible string.
I'll re-consider to use compatible strings for each SoCs.

> 
> > +
> > +
> > +Example:
> > +
> > +	eth: ethernet@65000000 {
> > +		compatible = "socionext,uniphier-ave4";
> > +		reg = <0x65000000 0x8500>;
> > +		interrupts = <0 66 4>;
> > +		pinctrl-names = "default";
> > +		pinctrl-0 = <&pinctrl_ether_rgmii>;
> > +		phy-mode = "rgmii";
> > +		socionext,desc-bits = <64>;
> > +		local-mac-address = [00 00 00 00 00 00];
> > +
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> 
> There is no phy-handle property, yet there clearly seems to be one
> attached, and I think Andrew now also responded to that in the driver
> patch, this needs fixing.

Surely phy-handle is missing in this. I'll fix it with mdio node.

> > +		ethphy: ethphy@1 {
> > +			reg = <1>;
> > +		};
> > +	};
> > 
> 
> 
> -- 
> Florian

---
Best Regards,
Kunihiko Hayashi
