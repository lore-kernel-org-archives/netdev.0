From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Mon, 17 Feb 2014 18:04:15 +0000
Message-ID: <20140217180415.GD19308@e106331-lin.cambridge.arm.com>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk>
 <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk>
 <CAGVrzcYbw5xLj-gwcup5i0gBdKDDGdyy5wAaEBp7m2E7f2bytg@mail.gmail.com>
 <53024A62.4050208@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:37263 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753688AbaBQSES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 13:04:18 -0500
Content-Disposition: inline
In-Reply-To: <53024A62.4050208@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 17, 2014 at 05:44:02PM +0000, Ben Dooks wrote:
> On 17/02/14 17:33, Florian Fainelli wrote:
> > Hi Ben,
> >
> > 2014-02-17 5:08 GMT-08:00 Ben Dooks <ben.dooks@codethink.co.uk>:
> >> Add new init-regs field for of_phy nodes and make sure these
> >> get applied when the phy is configured.
> >>
> >> This allows any phy node in an fdt to initialise registers
> >> that may not be set as standard by the driver at initialisation
> >> time, such as LED controls.
> >>
> >> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> >> ---
> >>   Documentation/devicetree/bindings/net/phy.txt | 12 ++++++
> >>   drivers/net/phy/phy_device.c                  | 59 ++++++++++++++++++++++++++-
> >>   2 files changed, 70 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> >> index 58307d0..48d8ded 100644
> >> --- a/Documentation/devicetree/bindings/net/phy.txt
> >> +++ b/Documentation/devicetree/bindings/net/phy.txt
> >> @@ -20,6 +20,8 @@ Optional Properties:
> >>     assume clause 22. The compatible list may also contain other
> >>     elements.
> >>   - max-speed: Maximum PHY supported speed (10, 100, 1000...)
> >> +- init-regs: Set of registers to modify at initialisation as a
> >> +    a set of <register set clear>
> >
> > Should be:
> >
> > "micrel,led-control-init-val" or something like that.
> >
> > first cell is the register address, according to the IEEE 802.3 clause 22
> > second cell is the set bitmask to apply to the register address
> > specified in the first cell
> > third cell is the clear bitmask to apply to the register address
> > specified in the second cell
> >
> > I would rather see this as a specific PHY node DT property for setting
> > the LED control register, because this is totally non-standard and you
> > are touching a proprietary register here.
> 
> I'd rather stay with this than splattering lots and lots of
> phy specific additions to each phy driver.

For something that's PHY-specific anyway? Should we remove the rest of
the "phy specific additions" that constitute a driver?

> This has the plus it lets board developers set registers in
> case of board specific initialisation values that are not
> already in the drivers.

This also has the minus that it lets board developers set registers in
arbitrary ways, creating new bugs that will require more effort to work
around in drivers.

If you update the DTs to describe the hardware to the kernel, then the
kernel can later be updated to handle specific PHYs better. That cannot
happen if you try to hide information from the kernel by giving it a
list of arbitrary magic numbers.

Drivers are the place such things should go. The DT is not a place for
shoddy bytecode.

Thanks,
Mark.
