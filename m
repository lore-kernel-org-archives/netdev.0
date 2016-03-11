From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/3] net: thunderx: Cleanup PHY probing code.
Date: Fri, 11 Mar 2016 09:41:06 -0800
Message-ID: <56E30332.7060003@caviumnetworks.com>
References: <1457714822-5754-1-git-send-email-ddaney.cavm@gmail.com> <1457714822-5754-2-git-send-email-ddaney.cavm@gmail.com> <20160311173125.GI3153@lunn.ch>
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
In-Reply-To: <20160311173125.GI3153@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2016 09:31 AM, Andrew Lunn wrote:
>> +		phy_np = of_parse_phandle(node, "phy-handle", 0);
>> +		/* If there is no phy or defective firmware presents
>> +		 * this cortina phy, for which there is no driver
>> +		 * support, ignore it.
>> +		 */
>> +		if (phy_np &&
>> +		    !of_device_is_compatible(phy_np, "cortina,cs4223-slice")) {
>
> Hi David
>
> What is a cortina,cs4223-slice,

It is 1/4 of:

https://www.inphi.com/products/cs4223.php

> and why does it need to be handled differently?
>

$ ls drivers/net/phy/*cortina*
ls: cannot access drivers/net/phy/*cortina*: No such file or directory

For this configuration of thunder_bgx.c, the use of a Linux PHY driver 
is optional.

The firmware should probably not specify a PHY here, but it does so we 
ignore it so we don't wait around forever for the non-existent driver to 
bind.
