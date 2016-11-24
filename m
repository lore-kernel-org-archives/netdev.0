From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ethtool: Protect {get,set}_phy_tunable
 with PHY device mutex
Date: Thu, 24 Nov 2016 16:02:46 -0500 (EST)
Message-ID: <20161124.160246.1074638964663356987.davem@davemloft.net>
References: <20161122215531.18212-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966127AbcKXVCy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:02:54 -0500
In-Reply-To: <20161122215531.18212-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 22 Nov 2016 13:55:31 -0800

> PHY drivers should be able to rely on the caller of {get,set}_tunable to
> have acquired the PHY device mutex, in order to both serialize against
> concurrent calls of these functions, but also against PHY state machine
> changes. All ethtool PHY-level functions do this, except
> {get,set}_tunable, so we make them consistent here as well.
> 
> We need to update the Microsemi PHY driver in the same commit to avoid
> introducing either deadlocks, or lack of proper locking.
> 
> Fixes: 968ad9da7e0e ("ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE")
> Fixes: 310d9ad57ae0 ("net: phy: Add downshift get/set support in Microsemi PHYs driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> 
> - also patch drivers/net/phy/mscc.c in the same commit

Applied, thanks Florian.
