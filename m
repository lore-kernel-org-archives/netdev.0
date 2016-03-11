From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 12:56:04 -0800
Message-ID: <56E330E4.9090800@gmail.com>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com> <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com> <20160311173125.GI3153@lunn.ch> <56E30332.7060003@caviumnetworks.com> <20160311180030.GB19277@lunn.ch> <56E30DDF.5040506@caviumnetworks.com> <20160311190627.GC19277@lunn.ch> <56E31E7A.6080905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	David Daney <ddaney@caviumnetworks.com>,
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
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E31E7A.6080905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2016 11:37 AM, Florian Fainelli wrote:
> On 11/03/16 11:06, Andrew Lunn wrote:
>>>> I don't see why it should wait around forever. I have boards with
>>>> Marvell PHYs, yet if i don't build the Marvell driver, the Ethernet
>>>> driver still loads, because the generic PHY driver is used instead.
>>>> Why does this not work here?
>>>
>>> As I said before, there is no driver for the device, so
>>> of_phy_find_device() will always return NULL.
>>
>> I'm not yet convinced this is true. I really do expect that the
>> generic PHY driver will bind to it. It might then go horribly wrong,
>> because it is not standard compliant, but that is a different issue.
>
> I concur with Andrew here, unless the PHY is guaranteed to return
> garbage when get_phy_id() is called, there is a good chance that the
> Generic PHY driver will be bound to this PHY device, or this is not
> happening for you for some reason?
>

get_phy_id() is working a designed.

For this phy, we have:

   compatible = "cortina,cs4223-slice";

Therefore get_phy_id() is being called with a is_c45 value of false.

get_phy_id() is returning a value of 0, which means that it succeeds, 
but the returned phy_id is 0xffffffff, which causes get_phy_device() to 
not create a phy_device, and no driver can be bound.

I know you are all skeptical, but I really think the best thing to do is 
not try to attach a phy driver when this compatible value is encountered.

It is a defective device tree, and I am attempting to handle it in the 
specific site where it can cause problems.

We are trying to distinguish between these two cases:

  - of_phy_find_device() returns NULL because driver is not yet bound

  - of_phy_find_device() returns NULL because "cortina,cs4223-slice"

I don't think we need to build some sort of frame work to handle things 
like this in a general way.

David Daney
