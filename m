From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Fri, 23 Sep 2016 22:51:02 -0400 (EDT)
Message-ID: <20160923.225102.776369878310265580.davem@davemloft.net>
References: <20160923210819.5753-1-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, tremyfr@gmail.com, andrew@lunn.ch,
        netdev@vger.kernel.org
To: jaedon.shin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752578AbcIXCvH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 22:51:07 -0400
In-Reply-To: <20160923210819.5753-1-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jaedon Shin <jaedon.shin@gmail.com>
Date: Sat, 24 Sep 2016 06:08:19 +0900

> This reverts commit 62469c76007e ("net: ethernet: bcmgenet: use phydev
> from struct net_device")
> 
> without this patch, we call twice bcmgenet_mii_reset, and that is intended:
> - first time from bcmgenet_power_up() to make sure the PHY is initialized
>   *before* we get to initialize the UniMAC, this is critical
> - second time from bcmgenet_mii_probe(), through the normal phy_init_hw()
> 
> with this patch, we only get to call bcmgenet_mii_reset once, in
> bcmgenet_mii_probe() because the first time in bcmgenet_power_up(),
> dev->phydev is NULL, because of a prior call to phy_disconnect() in
> bcmgenet_close(), unfortunately, there has been MAC activity, so the PHY
> gets in a bad state
> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>

This is needed by the ksettings commit that happened right after this
one, so if you want this reverted you have to revert both commits.
