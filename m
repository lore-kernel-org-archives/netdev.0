From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH] net: stmmac: Handle possible fixed-link with
 need_mdio_ids
Date: Sat, 26 Aug 2017 09:27:22 +0200
Message-ID: <20170826072722.GA22388@Red>
References: <20170825144208.24503-1-clabbe.montjoie@gmail.com>
 <20170825162827.GA4207@lunn.ch>
 <0e914e7f-3231-66e4-07fb-dd0bea5838a8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0e914e7f-3231-66e4-07fb-dd0bea5838a8@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2017 at 09:45:23AM -0700, Florian Fainelli wrote:
> On 08/25/2017 09:28 AM, Andrew Lunn wrote:
> > On Fri, Aug 25, 2017 at 04:42:08PM +0200, Corentin Labbe wrote:
> >> In case of fixed link, there are no mdio node.
> >> This patch add a test for fixed-link for bypassing MDIO node register.
> > 
> > The two are not mutually exclusive. E.g.
> > vf610-zii-dev.dtsi/vf610-zii-dev-rev-b.dts.  It has a fixed-link on
> > the FEC ethernet controller, and an Ethernet switch on the MDIO bus.
> > 
> > If anybody ever wants to use a switch with the stmmac, this will be
> > required.
> 
> This is already done in the Lamobo R1 DTS file so it would be nice not
> to break this use case:
> 
> &gmac {
>         pinctrl-names = "default";
>         pinctrl-0 = <&gmac_pins_rgmii_a>;
>         phy-mode = "rgmii";
>         phy-supply = <&reg_gmac_3v3>;
>         status = "okay";
> 
>         fixed-link {
>                 speed = <1000>;
>                 full-duplex;
>         };
> 
>         mdio {
>                 compatible = "snps,dwmac-mdio";
>                 #address-cells = <1>;
>                 #size-cells = <0>;
> 
>                 switch: ethernet-switch@1e {
>                         compatible = "brcm,bcm53125";
>                         reg = <30>;
>                         #address-cells = <1>;
>                         #size-cells = <0>;
> 
> 
> > 
> > 	Andrew
> > 
> 

Sorry, I have made a bad commit message.
This commit only change behaviour for nodes that match need_mdio_ids.
The behaviour for snps,dwmac-mdio does not change as it is handled in follow up of the "ifthenelse"
I will resent it with correct commit message.

Regards
