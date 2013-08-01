From: Sean Cross <xobs@kosagi.com>
Subject: Re: [PATCH] net/phy: micrel: Add OF configuration support
Date: Thu, 1 Aug 2013 14:23:27 +0800
Message-ID: <90629591B1A5485C845DAC6572F25924@kosagi.com>
References: <1375330601-3609-1-git-send-email-xobs@kosagi.com>
 <1375330601-3609-2-git-send-email-xobs@kosagi.com>
 <9848F2DB572E5649BA045B288BE08FBE015E3F06@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "=?utf-8?Q?netdev=40vger.kernel.org?=" <netdev@vger.kernel.org>,
	"=?utf-8?Q?devicetree=40vger.kernel.org?="
	<devicetree@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"=?utf-8?Q?stephen=40networkplumber.org?="
	<stephen@networkplumber.org>, Steven Rostedt <rostedt@goodmis.org>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:52395 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200Ab3HAGXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 02:23:32 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE015E3F06@039-SN2MPN1-023.039d.mgd.msft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, August 1, 2013 at 1:31 PM, Duan Fugang-B38611 wrote:
> On Thu, Aug 01, 2013 at 12:17 PM, Sean Cross wrote:
> 
> > +/* Write/read to/from extended registers */
> > +#define MII_KSZPHY_EXTREG 0x0b
> > +#define KSZPHY_EXTREG_WRITE 0x8000
> > +
> > +#define MII_KSZPHY_EXTREG_WRITE 0x0c
> > +#define MII_KSZPHY_EXTREG_READ 0x0d
> > +
> > +/* Write/read to/from extended registers */
> > +#define MII_KSZPHY_EXTREG 0x0b
> > +#define KSZPHY_EXTREG_WRITE 0x8000
> > +
> > +#define MII_KSZPHY_EXTREG_WRITE 0x0c
> > +#define MII_KSZPHY_EXTREG_READ 0x0d
> > +
> 
> 
> 
> Pls don't re-define the registers address and field.
My fault.  I'll remove this redundancy. 
> > + if (!of_property_read_u32(of_node,
> > + "micrel,clk-control-pad-skew",
> > + &val))
> > + kszphy_extended_write(phydev,
> > + MII_KSZPHY_CLK_CONTROL_PAD_SKEW,
> > + val);
> 
> 
> 
> When re-set rx/tx clock delay, rx/tx control delay, it is better to do dummy read the extended MII_KSZPHY_CLK_CONTROL_PAD_SKEW register one time.
Can you please explain this?  I don't see anything in the datasheet I'm looking at (ksz9021rl) describing dummy reads.  If both tx and rx skew are adjusted, should there be two dummy reads or just one? 
