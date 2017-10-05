From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH 2/3 v2] net: phy: DP83822 initial driver submission
Date: Thu, 5 Oct 2017 15:06:36 -0500
Message-ID: <7dc268a5-de82-35c8-f793-a210ced69b73@ti.com>
References: <20171004182031.13794-1-dmurphy@ti.com>
 <20171004182031.13794-2-dmurphy@ti.com>
 <9235D6609DB808459E95D78E17F2E43D40B3F9A9@CHN-SV-EXMX02.mchp-main.com>
 <20171004235307.GD16612@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>, <afd@ti.com>
To: Andrew Lunn <andrew@lunn.ch>, <Woojung.Huh@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:11693 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbdJEUGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 16:06:48 -0400
In-Reply-To: <20171004235307.GD16612@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew

On 10/04/2017 06:53 PM, Andrew Lunn wrote:
> On Wed, Oct 04, 2017 at 10:44:36PM +0000, Woojung.Huh@microchip.com wrote:
>>> +static int dp83822_suspend(struct phy_device *phydev)
>>> +{
>>> +	int value;
>>> +
>>> +	mutex_lock(&phydev->lock);
>>> +	value = phy_read_mmd(phydev, DP83822_DEVADDR,
>>> MII_DP83822_WOL_CFG);
>>> +	mutex_unlock(&phydev->lock);
> 
>> Would we need mutex to access phy_read_mmd()?
>> phy_read_mmd() has mdio_lock for indirect access.
> 
> Hi Woojung
> 
> The mdio lock is not sufficient. It protects against two mdio
> accesses. But here we need to protect against two phy operations.
> There is a danger something else tries to access the phy during
> suspend.
> 
>>> +	if (!(value & DP83822_WOL_EN))
>>> +		genphy_suspend(phydev);
> 
> Releasing the lock before calling genphy_suspend() is not so nice.
> Maybe add a version which assumes the lock has already been taken?
> 

The marvell driver does not take a lock and calls genphy_suspend/resume
so I am wondering if this driver needs to take a lock.

The at803x needs to take the lock because it does not call into the genphy
functions.

Dan

>       Andrew
> 


-- 
------------------
Dan Murphy
