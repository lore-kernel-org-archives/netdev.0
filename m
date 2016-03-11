From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 11:37:30 -0800
Message-ID: <56E31E7A.6080905@gmail.com>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com>
 <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com>
 <20160311173125.GI3153@lunn.ch> <56E30332.7060003@caviumnetworks.com>
 <20160311180030.GB19277@lunn.ch> <56E30DDF.5040506@caviumnetworks.com>
 <20160311190627.GC19277@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Robert Richter <rric@kernel.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: Andrew Lunn <andrew@lunn.ch>,
	David Daney <ddaney@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160311190627.GC19277@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/16 11:06, Andrew Lunn wrote:
>>> I don't see why it should wait around forever. I have boards with
>>> Marvell PHYs, yet if i don't build the Marvell driver, the Ethernet
>>> driver still loads, because the generic PHY driver is used instead.
>>> Why does this not work here?
>>
>> As I said before, there is no driver for the device, so
>> of_phy_find_device() will always return NULL.
> 
> I'm not yet convinced this is true. I really do expect that the
> generic PHY driver will bind to it. It might then go horribly wrong,
> because it is not standard compliant, but that is a different issue.

I concur with Andrew here, unless the PHY is guaranteed to return
garbage when get_phy_id() is called, there is a good chance that the
Generic PHY driver will be bound to this PHY device, or this is not
happening for you for some reason?

> 
> The generic driver should probably have a black list for such devices.
> This is a PHY issue, not an MDIO issue, and the problem should be
> solved in the PHY layer, not in one MDIO driver.

I considered the possibility once of disabling the generic PHY driver,
such that systems where the vendor-specific PHY driver is expected to be
used could utilize that. That does not play well with the fixed PHYs
using the generic PHY driver though, anyway, I am digressing.

> 
> We should also consider what happens when somebody actually writes a
> driver for this PHY. Are you not going to use it?
> 
> Before this patchset, you did not special case this compatible
> string. So at the very least, you need to split this into a separate
> patch, so the maintainers can ACK/NACK it, independent of the other
> change it is embedded in.
> 
>        Andrew
> 


-- 
Florian
