From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 20:51:39 +0100
Message-ID: <20170609195139.GT4902@n2100.armlinux.org.uk>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain>
 <20170609132624.GC20756@lunn.ch>
 <20170609140922.GD31464@kwain>
 <20170609144936.GF20756@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jason@lakedaemon.net, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52632 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751536AbdFITwD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:52:03 -0400
Content-Disposition: inline
In-Reply-To: <20170609144936.GF20756@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 04:49:36PM +0200, Andrew Lunn wrote:
> On Fri, Jun 09, 2017 at 04:09:22PM +0200, Antoine Tenart wrote:
> > The MDIO/xMDIO registers are embedded into the network controller. The
> > mvmdio driver was created at first to abstract this functionality
> > outside the network controller driver because it is shared between all
> > ports and used in different IPs. So it's not really devices per say.
> > 
> > Looking at the datasheet/schematics there are two hardware buses, one
> > for c22 and one for c45. So we should keep two separate nodes to
> > describe the two interfaces. From what I read c45 is backward
> > compatible with c22 so the xSMI interface should be capable to speak to
> > c22 PHYs as well.
> 
> The on the wire protocol of c45 is backwards compatible with c22, in
> that a c22 device will not get confused by a c45 transaction on the
> bus. A c22 device will just ignore it. You cannot talk to a c22 device
> using c45.

>From what I can tell, having 'scoped the MDIO line and tried writing
several different values to the XSMI registers, it is not possible
for the XSMI block to generate C22 frame structures - the "start"
bits are always "00", and I can't make them the required "01" for C22.

However, I can confirm that bits 26 and 27 of the XSMI register are used
directly for the OP field (so 0 << 26 produces a C45 address frame.)  I
suspect, although I haven't delved that deeply (yet) that bit 28 sets
whether XSMI produces an address cycle itself along with the data cycle.

Bit 31 appears to be writable, but has no effect on the frame structure.

> What i'm worried about is there being one set of MDC/MDIO lines. You
> should not expose that to linux as two mdio busses. It is one bus.

We're independent - the SMI and XSMI blocks are two entirely separate
interfaces with entirely separate hardware MDC/MDIO lines.  The XSMI
MDC/MDIO lines remain at logic '1' while phylib polls the PHY via
the SMI interface.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
