From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "net: dsa: bcm_sf2: Defer port
 enabling to calling port_enable"
Date: Sun, 01 Oct 2017 04:02:50 +0100 (WEST)
Message-ID: <20171001.040250.1687037732691944138.davem@davemloft.net>
References: <20170928181906.3156-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928181906.3156-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 28 Sep 2017 11:19:06 -0700

> This reverts commit e85ec74ace29 ("net: dsa: bcm_sf2: Defer port
> enabling to calling port_enable") because this now makes an unbind
> followed by a bind to fail connecting to the ingrated PHY.
> 
> What this patch missed is that we need the PHY to be enabled with
> bcm_sf2_gphy_enable_set() before probing it on the MDIO bus. This is
> correctly done in the ops->setup() function, but by the time
> ops->port_enable() runs, this is too late. Upon unbind we would power
> down the PHY, and so when we would bind again, the PHY would be left
> powered off.
> 
> Fixes: e85ec74ace29 ("net: dsa: bcm_sf2: Defer port enabling to calling port_enable")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
