From: Sean Cross <xobs@kosagi.com>
Subject: Re: [PATCH v3] net/phy: micrel: Add OF configuration support
 for ksz9021
Date: Mon, 5 Aug 2013 10:23:58 +0800
Message-ID: <5CE77AC80B4242C98833109D6F1C9F85@kosagi.com>
References: <1375348757-12856-1-git-send-email-xobs@kosagi.com>
 <1375348757-12856-2-git-send-email-xobs@kosagi.com>
 <9848F2DB572E5649BA045B288BE08FBE015ED2F7@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	"=?utf-8?Q?netdev=40vger.kernel.org?=" <netdev@vger.kernel.org>,
	"=?utf-8?Q?devicetree=40vger.kernel.org?="
	<devicetree@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"=?utf-8?Q?stephen=40networkplumber.org?="
	<stephen@networkplumber.org>, Steven Rostedt <rostedt@goodmis.org>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:39767 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab3HECYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Aug 2013 22:24:06 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015ED2F7@039-SN2MPN1-023.039d.mgd.msft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 5 August, 2013 at 9:58 AM, Duan Fugang-B38611 wrote:
> From: Sean Cross [mailto:xobs@kosagi.com]
> Data: Thursday, August 01, 2013 5:19 PM
> 
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/micrel-ksz9021.txt
> > @@ -0,0 +1,19 @@
> > +Micrel KSZ9021 Gigabit Ethernet PHY
> > +
> > +Some boards require special tuning values, particularly when it comes
> > +to clock delays. You can specify clock delay values by adding
> > +micrel-specific properties to an Ethernet OF device node.
> > +
> > +Optional properties:
> > +- micrel,clk-control-pad-skew : Timing offset for the MII clock line
> > +- micrel,rx-data-pad-skew : Timing offset for the RX MII pad
> > +- micrel,tx-data-pad-skew : Timing offset for the TX MII pad
> > +
> > +Example:
> > + &enet {
> > + micrel,clk-control-pad-skew = <0xf0f0>;
> > + micrel,rx-data-pad-skew = <0x0000>;
> > + micrel,tx-data-pad-skew = <0xffff>;
> > + status = "okay";
> > + };
> > +
> 
> 
> 
> The phy binding must be the phy node, not the ethernet node.
> Pls refer to: 
> Documentation/devicetree/booting-without-of.txt
> Documentation/devicetree/bindings/net/phy.txt

This won't necessarily work.  In my board, I don't think it's possible to manually specify the PHY, as most of the fields required by the OF PHY node don't apply to this device (at least according to phy.txt).  There are no interrupts, no interrupt parent, and it's unclear what the reg or linux,phandle fields do.  All of these are required fields, none of which seem to apply to this particular board.  Furthermore, it doesn't seem to be possible to specify a particular PHY, such as the ksz9021.

I see the pattern of getting OF settings from a parent's node used elsewhere in the kernel.  For example, in mmc_of_parse(), or more similarly in the chipidea ci_hdrc_probe() driver.  
> > +static int ksz9021_config_init(struct phy_device *phydev) {
> > + struct device *dev = &phydev->dev;
> > + struct device_node *of_node = dev->of_node;
> > +
> > + if (!of_node && dev->parent->of_node)
> > + of_node = dev->parent->of_node;
> > +
> 
> 
> If phy binding is phy node, there only check of_node, don't re-evaluate the phy node.
It's done this way in case it's not possible to add a phy node, as in this case. 
