From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: phy: Relax error checking on
 sysfs_create_link()
Date: Sat, 27 May 2017 19:58:40 -0400 (EDT)
Message-ID: <20170527.195840.838540630181121791.davem@davemloft.net>
References: <20170527174225.9447-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, Woojung.Huh@microchip.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52958 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdE0X6v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 19:58:51 -0400
In-Reply-To: <20170527174225.9447-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 27 May 2017 10:42:25 -0700

> Some Ethernet drivers will attach/connect to a PHY device before calling
> register_netdevice() which is responsible for calling netdev_register_kobject()
> which would do the network device's kobject initialization. In such a case,
> sysfs_create_link() would return -ENOENT because the network device's kobject
> is not ready yet, and we would fail to connect to the PHY device.
> 
> In order to keep things simple and symetrical, we just take the success path as
> indicative of the ability to access the network device's kobject, and create
> the second link if that's the case.
> 
> Fixes: 5568363f0cb3 ("net: phy: Create sysfs reciprocal links for attached_dev/phydev")
> Reported-by: Woojung Hung <Woojung.Huh@microchip.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> - make sure phydev->sysfs_links is set to false before setting again

Applied, thanks Florian.
