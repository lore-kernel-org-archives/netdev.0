From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: fec: normalize return value of
 pm_runtime_get_sync() in MDIO write
Date: Thu, 3 Sep 2015 21:49:29 +0200
Message-ID: <20150903194929.GB19471@lunn.ch>
References: <55E8A1B6.2080008@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	=?iso-8859-1?Q?=22Lothar_Wa=DFmann=22?= <LW@KARO-electronics.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55E8A1B6.2080008@maciej.szmigiero.name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 03, 2015 at 09:38:30PM +0200, Maciej S. Szmigiero wrote:
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

Fixes: 8fff755e9f8d ("net: fec: Ensure clocks are enabled while using mdio bus")

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
