From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v3 2/3] dt-binding: net: sfp binding documentation
Date: Mon, 4 Sep 2017 08:55:12 +0300
Message-ID: <20170904055512.f34afju4crd2ciu6@sapphire.tkos.co.il>
References: <c2a27566a8eb358ee2566a213c385d0bf3d64307.1504441874.git.baruch@tkos.co.il>
 <01ae7bc45d68322669d18a4feeaeef733ba888d7.1504441874.git.baruch@tkos.co.il>
 <20170903204634.GZ20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:47319 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750782AbdIDFzR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 01:55:17 -0400
Content-Disposition: inline
In-Reply-To: <20170903204634.GZ20805@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Sun, Sep 03, 2017 at 09:46:35PM +0100, Russell King - ARM Linux wrote:
> On Sun, Sep 03, 2017 at 03:31:13PM +0300, Baruch Siach wrote:
> > Add device-tree binding documentation SFP transceivers. Support for SFP
> > transceivers has been recently introduced (drivers/net/phy/sfp.c).
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> > v3:
> >   Mention gpios phandle and specifier
> >   Mention the polarity of each gpio
> >   Fix example property names
> > 
> > v2:
> >   Rename -gpio properties to -gpios
> >   Rename the rate-select-gpio property to rate-select0-gpios
> >   Add the rate-select1-gpios property
> >   Add examples
> > ---
> >  Documentation/devicetree/bindings/net/sff,sfp.txt | 78 +++++++++++++++++++++++
> >  1 file changed, 78 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/net/sff,sfp.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > new file mode 100644
> > index 000000000000..b98ee5945265
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > @@ -0,0 +1,78 @@
> > +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> > +Transceiver
> > +
> > +Required properties:
> > +
> > +- compatible : must be "sff,sfp"
> > +
> > +Optional Properties:
> > +
> > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > +  interface
> > +
> > +- moddef0-gpios : GPIO phandle and a single specifier of the MOD-DEF0 (AKA
> > +  Mod_ABS) module presence input gpio signal, active (module absent) high
> > +
> > +- los-gpios : GPIO phandle and a single specifier of the Receiver Loss of
> > +  Signal Indication input gpio signal, active (signal lost) high
> > +
> > +- tx-fault-gpios : GPIO phandle and a single specifier of the Module
> > +  Transmitter Fault input gpio signal, active (fault condition) high
> > +
> > +- tx-disable-gpios : GPIO phandle and a single specifier of the Transmitter
> > +  Disable output gpio signal, active (Tx disable) high
> > +
> > +- rate-select0-gpios : GPIO phandle and a single specifier of the Rx Signaling
> > +  Rate Select (AKA RS0) output gpio signal, low: low Rx rate, high: high Rx
> > +  rate
> > +
> > +- rate-select1-gpios : GPIO phandle and a single specifier of the Tx Signaling
> > +  Rate Select (AKA RS1) output gpio signal (SFP+ only), low: low Tx rate,
> > +  high: high Tx rate
> > +
> > +Example #1: Direct serdes to SFP connection
> > +
> > +sfp_eth3: sfp-eth3 {
> > +	compatible = "sff,sfp";
> > +	i2c-bus = <&sfp_1g_i2c>;
> > +	los-gpios = <&cpm_gpio2 22 GPIO_ACTIVE_HIGH>;
> > +	moddef0-gpios = <&cpm_gpio2 21 GPIO_ACTIVE_LOW>;
> > +	pinctrl-names = "default";
> > +	pinctrl-0 = <&cpm_sfp_1g_pins &cps_sfp_1g_pins>;
> > +	tx-disable-gpios = <&cps_gpio1 24 GPIO_ACTIVE_HIGH>;
> > +	tx-fault-gpios = <&cpm_gpio2 19 GPIO_ACTIVE_HIGH>;
> > +};
> > +
> > +&cps_emac3 {
> > +	phy-mode = "sgmii";
> > +	phy-names = "comphy";
> > +	phys = <&cps_comphy 5 COMPHY_SGMII2>;
> 
> I don't like this level of example - SGMII is Cisco SGMII which is not
> the same as 1000Base-X - the two are incompatible.  Fibre SFP modules
> only work with 1000Base-X.
> 
> The SFP/phylink takes care of informing the MAC which mode it should
> be in, and the MAC must configure itself appropriately in response to
> that, otherwise the module can't be supported.

So, if I understand you correctly, the PHY mode should not be coded in the DT 
since the mode is run-time configurable, and depends on the SFP module. Is 
that correct?

How about the following then:

&cps_emac3 {
        phy-names = "comphy";
        phys = <&cps_comphy 5>;
        sfp = <&sfp_eth3>;
};

Thanks,
baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
