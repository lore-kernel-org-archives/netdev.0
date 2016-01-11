From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v2 1/2] net: tc35815: Fix build error due to
 missed API change
Date: Sun, 10 Jan 2016 23:31:41 -0500 (EST)
Message-ID: <20160110.233141.1537853356042839675.davem@davemloft.net>
References: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452438645-29440-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun, 10 Jan 2016 07:10:44 -0800

> Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
> a bus") introduces an API to access mii_bus structures, but missed to
> update the tc35815 driver. This results in the following error message.
> 
> drivers/net/ethernet/toshiba/tc35815.c: In function 'tc_mii_probe':
> drivers/net/ethernet/toshiba/tc35815.c:617:18: error:
> 	'struct mii_bus' has no member named 'phy_map'
> drivers/net/ethernet/toshiba/tc35815.c:623:24: error:
> 	'struct mii_bus' has no member named 'phy_map'
> 
> Instead of looping over the list of phy addresses to find a phy chip,
> use phy_find_first(). While the intent of the original code was to return
> an error if more than one phy was specified, this code path was never
> executed because the loop aborted after finding the first phy. The
> original code is therefore semantically identical to phy_find_first(),
> thus it is simpler and more straightforward to use phy_find_first()
> directly.
> 
> Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
