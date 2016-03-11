From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 19:00:30 +0100
Message-ID: <20160311180030.GB19277@lunn.ch>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com>
 <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com>
 <20160311173125.GI3153@lunn.ch>
 <56E30332.7060003@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 Florian Fainelli <f.fainelli@gmail.com>, Robert Richter <rric@kernel.org>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 netdev@vger.kernel.org, David Daney <david.daney@cavium.com>,
 linux-kernel@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 David Daney <ddaney.cavm@gmail.com>, Kumar Gala <galak@codeaurora.org>,
 Sunil Goutham <sgoutham@cavium.com>,
 Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <56E30332.7060003@caviumnetworks.com>
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

On Fri, Mar 11, 2016 at 09:41:06AM -0800, David Daney wrote:
> On 03/11/2016 09:31 AM, Andrew Lunn wrote:
> >>+		phy_np = of_parse_phandle(node, "phy-handle", 0);
> >>+		/* If there is no phy or defective firmware presents
> >>+		 * this cortina phy, for which there is no driver
> >>+		 * support, ignore it.
> >>+		 */
> >>+		if (phy_np &&
> >>+		    !of_device_is_compatible(phy_np, "cortina,cs4223-slice")) {
> >
> >Hi David
> >
> >What is a cortina,cs4223-slice,
> 
> It is 1/4 of:
> 
> https://www.inphi.com/products/cs4223.php
> 
> >and why does it need to be handled differently?
> >
> 
> $ ls drivers/net/phy/*cortina*
> ls: cannot access drivers/net/phy/*cortina*: No such file or directory
> 
> For this configuration of thunder_bgx.c, the use of a Linux PHY
> driver is optional.
> 
> The firmware should probably not specify a PHY here, but it does so
> we ignore it so we don't wait around forever for the non-existent
> driver to bind.
 
Hi David

I don't see why it should wait around forever. I have boards with
Marvell PHYs, yet if i don't build the Marvell driver, the Ethernet
driver still loads, because the generic PHY driver is used instead.
Why does this not work here?

Also, Documentation/devicetree/bindings/net/phy.txt says:

 compatible: Compatible list, may contain
  "ethernet-phy-ieee802.3-c22" or "ethernet-phy-ieee802.3-c45" for
  PHYs that implement IEEE802.3 clause 22 or IEEE802.3 clause 45
  specifications. If neither of these are specified, the default is to
  assume clause 22.

  If the phy's identifier is known then the list may contain an entry
  of the form: "ethernet-phy-idAAAA.BBBB" where
     AAAA - The value of the 16 bit Phy Identifier 1 register as
            4 hex digits. This is the chip vendor OUI bits 3:18
     BBBB - The value of the 16 bit Phy Identifier 2 register as
            4 hex digits. This is the chip vendor OUI bits 19:24,
            followed by 10 bits of a vendor specific ID.

  The compatible list should not contain other values than those
  listed here.

So having "cortina,cs4223-slice" in the compatible string goes against
the binding. To make this work, you probably need to extend the
whitelist_phys list in of_mdio.c.

       Andrew
