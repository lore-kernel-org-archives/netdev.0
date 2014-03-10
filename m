From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix uninitalized WOL parameters in
 phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 16:23:49 -0400 (EDT)
Message-ID: <20140310.162349.2007153760780671206.davem@davemloft.net>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1394419893.15968.88.camel@deadeye.wl.decadent.org.uk>
	<531D98D1.4000707@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531D98D1.4000707@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Mon, 10 Mar 2014 10:49:53 +0000

> void phy_ethtool_get_wol(struct phy_device *phydev, struct
> ethtool_wolinfo *wol)
> {
> 	memset(wol, 0, sizeof(*wol));
> 
> 	if (phydev && phydev->drv->get_wol)
> 		phydev->drv->get_wol(phydev, wol);
> }
> 
> That would also simplify above drivers down to e.g:
> 
> static void cpsw_get_wol(struct net_device *ndev, struct
> ethtool_wolinfo *wol)
> {
> 	struct cpsw_priv *priv = netdev_priv(ndev);
> 	int slave_no = cpsw_slave_index(priv);
> 	phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
> }
> 
> instead of:
> 
> static void cpsw_get_wol(struct net_device *ndev, struct
> ethtool_wolinfo *wol)
> {
> 	struct cpsw_priv *priv = netdev_priv(ndev);
> 	int slave_no = cpsw_slave_index(priv);
> 
> 	wol->supported = 0;
> 	wol->wolopts = 0;
> 
> 	if (priv->slaves[slave_no].phy)
> 		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
> }

Agreed, since phy_ethtool_get_wol() is the common routine used by the drivers,
we should make it clear the structure.
