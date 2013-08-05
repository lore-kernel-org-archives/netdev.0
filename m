From: Sean Cross <xobs@kosagi.com>
Subject: Re: [PATCH v5] net/phy: micrel: Add OF configuration support
 for ksz9021
Date: Mon, 5 Aug 2013 15:54:51 +0800
Message-ID: <B521A8659CBF426297A6B0D2EB3281DB@kosagi.com>
References: <1375686248-17995-1-git-send-email-xobs@kosagi.com>
 <1375686248-17995-2-git-send-email-xobs@kosagi.com>
 <9848F2DB572E5649BA045B288BE08FBE015EECA0@039-SN2MPN1-023.039d.mgd.msft.net>
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
Received: from mail1.g1.pair.com ([66.39.3.162]:27814 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab3HEHy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 03:54:57 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015EECA0@039-SN2MPN1-023.039d.mgd.msft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-- 
Sean Cross


On Monday, August 5, 2013 at 3:41 PM, Duan Fugang-B38611 wrote:

> From: Sean Cross [mailto:xobs@kosagi.com]
> Data: Monday, August 05, 2013 3:04 PM
> > To: Sascha Hauer; Duan Fugang-B38611; netdev@vger.kernel.org (mailto:netdev@vger.kernel.org);
> > devicetree@vger.kernel.org (mailto:devicetree@vger.kernel.org)
> > Cc: David Miller; stephen@networkplumber.org (mailto:stephen@networkplumber.org); Steven Rostedt; Sean Cross
> > Subject: [PATCH v5] net/phy: micrel: Add OF configuration support for
> > ksz9021
> > 
> > Some boards require custom PHY configuration, for example due to trace
> > length differences. Add the ability to configure these registers in order
> > to get the PHY to function on boards that need it.
> > 
> > Because PHYs are auto-detected based on MDIO device IDs, allow PHY
> > configuration to be specified in the parent Ethernet device node if no PHY
> > device node is present.
> > 
> > Signed-off-by: Sean Cross <xobs@kosagi.com (mailto:xobs@kosagi.com)>
> > ---
> > +static int ksz9021_load_values_from_of(struct phy_device *phydev,
> > + struct device_node *of_node, u16 reg,
> > + char *field1, char *field2,
> > + char *field3, char *field4)
> > +{
> > + int val1 = -1;
> > + int val2 = -2;
> > + int val3 = -3;
> > + int val4 = -4;
> > + int newval;
> > + int matches = 0;
> > +
> > + if (!of_property_read_u32(of_node, field1, &val1))
> > + matches++;
> > +
> > + if (!of_property_read_u32(of_node, field2, &val2))
> > + matches++;
> > +
> > + if (!of_property_read_u32(of_node, field3, &val3))
> > + matches++;
> > +
> > + if (!of_property_read_u32(of_node, field4, &val4))
> > + matches++;
> > +
> > + if (!matches)
> > + return 0;
> > +
> > + if (matches < 4)
> > + newval = kszphy_extended_read(phydev, reg);
> > + else
> > + newval = 0;
> > +
> > + if (val1 != -1)
> > + newval = ((newval & 0xfff0) | ((val1/200)&0xf) << 0);
> > +
> > + if (val2 != -1)
> > + newval = ((newval & 0xff0f) | ((val2/200)&0xf) << 4);
> 
> 
> Must be : Newval |= ...
> > +
> > + if (val3 != -1)
> > + newval = ((newval & 0xf0ff) | ((val3/200)&0xf) << 8);
> 
> 
> Must be : Newval |= ...
> > +
> > + if (val4 != -1)
> > + newval = ((newval & 0x0fff) | ((val4/200)&0xf) << 12);
> 
> 
> Must be : Newval |= ...
> > +
> > + return kszphy_extended_write(phydev, reg, newval); }
> 

If all four fields are updated, then newval will start out as 0.  If only a few fields are updated, then newval will start out with the previous value.

If a given field is mentioned in the device tree file, then its value will change to something other than -1.  If the value remains at -1, then that particular field could not be found, and it should not be modified. 
