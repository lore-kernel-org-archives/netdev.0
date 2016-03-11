From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 11:34:24 -0800
Message-ID: <56E31DC0.5020402@caviumnetworks.com>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com> <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com> <20160311173125.GI3153@lunn.ch> <56E30332.7060003@caviumnetworks.com> <20160311180030.GB19277@lunn.ch> <56E30DDF.5040506@caviumnetworks.com> <20160311190627.GC19277@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	<linux-kernel@vger.kernel.org>,
	David Daney <david.daney@cavium.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160311190627.GC19277@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2016 11:06 AM, Andrew Lunn wrote:
>>> I don't see why it should wait around forever. I have boards with
>>> Marvell PHYs, yet if i don't build the Marvell driver, the Ethernet
>>> driver still loads, because the generic PHY driver is used instead.
>>> Why does this not work here?
>>
>> As I said before, there is no driver for the device, so
>> of_phy_find_device() will always return NULL.
>
> I'm not yet convinced this is true.

Which part don't you believe?  Is it:

   - there is no driver for the device.

or

   - for PHYs with no driver, of_phy_find_device() will return NULL

> I really do expect that the
> generic PHY driver will bind to it. It might then go horribly wrong,
> because it is not standard compliant, but that is a different issue.
>

At a higher level, the way we handle either of:

   - Lack of a driver.

   - "Horribly wrong" driver

is the same, we cannot use a PHY driver.

> The generic driver should probably have a black list for such devices.
> This is a PHY issue, not an MDIO issue, and the problem should be
> solved in the PHY layer, not in one MDIO driver.

This isn't an MDIO driver patch.  This is more about handling a 
defective device tree in the only driver (a non-MDIO driver) that will 
ever see such a device tree node.

>
> We should also consider what happens when somebody actually writes a
> driver for this PHY.   Are you not going to use it?

Easy to answer: We remove the "&& !of_device_is_compatible(phy_np, 
"cortina,cs4223-slice")" clause from this driver.

>
> Before this patchset, you did not special case this compatible
> string. So at the very least, you need to split this into a separate
> patch, so the maintainers can ACK/NACK it, independent of the other
> change it is embedded in.
>

I can, and will, do that.

Thanks,
David Daney
