From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: normalize return value of
 pm_runtime_get_sync() in MDIO write
Date: Sat, 05 Sep 2015 22:04:25 -0700 (PDT)
Message-ID: <20150905.220425.2069850242655969926.davem@davemloft.net>
References: <55E8A1B6.2080008@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, B38611@freescale.com,
	Frank.Li@freescale.com, LW@KARO-electronics.de,
	fabio.estevam@freescale.com, andrew@lunn.ch,
	linux-kernel@vger.kernel.org
To: mail@maciej.szmigiero.name
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E8A1B6.2080008@maciej.szmigiero.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Date: Thu, 03 Sep 2015 21:38:30 +0200

> If fec MDIO write method succeeds its return value comes from
> call to pm_runtime_get_sync().
> But pm_runtime_get_sync() can also return 1.
> 
> In case of Micrel KSZ9031 PHY this value will then
> be returned along the call chain of phy_write() ->
> ksz9031_extended_write() -> ksz9031_center_flp_timing() ->
> ksz9031_config_init() -> phy_init_hw() -> phy_attach_direct() ->
> phy_connect_direct().
> 
> Then phy_connect() will cast it into a pointer using ERR_PTR(),
> which then fec_enet_mii_probe() will try to dereference
> resulting in an oops.
> 
> Fix it by normalizing return value of pm_runtime_get_sync()
> to be zero if positive in MDIO write method.
> 
> Signed-off-by: Maciej Szmigiero <mail@maciej.szmigiero.name>

Applied.
