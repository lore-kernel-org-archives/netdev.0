From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 22:35:16 +0100
Message-ID: <20160311213516.GE19277@lunn.ch>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com>
 <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com>
 <20160311173125.GI3153@lunn.ch>
 <56E30332.7060003@caviumnetworks.com>
 <20160311180030.GB19277@lunn.ch>
 <56E30DDF.5040506@caviumnetworks.com>
 <20160311190627.GC19277@lunn.ch>
 <56E31E7A.6080905@gmail.com>
 <56E330E4.9090800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robert Richter <rric@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	netdev@vger.kernel.org, David Daney <david.daney@cavium.com>,
	David Daney <ddaney@caviumnetworks.com>,
	linux-kernel@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Kumar Gala <galak@codeaurora.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55126 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbcCKVfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 16:35:25 -0500
Content-Disposition: inline
In-Reply-To: <56E330E4.9090800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For this phy, we have:
> 
>   compatible = "cortina,cs4223-slice";

That actually means something else is happening, i think.

of_mdiobus_register() looks at the children, and decides if each child
is a phy or an mdio device, by calling of_mdiobus_child_is_phy().
Since this compatible string is not in whitelist_phys[], it will
return false. of_mdiobus_register() will then do a
of_mdiobus_register_device(). This compatible means it is an MDIO
device, not a PHY. So when you later call of_phy_find_device() it is
always going to return NULL, because there is no PHY there, only an
MDIO device.

How usable is the hardware without a PHY driver? Is a better solution
that your write a very minimal PHY driver?

     Andrew
