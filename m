From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 05/11] net: dsa: qca8k: remove qca8k_get_eee
Date: Mon, 31 Jul 2017 18:17:13 -0400
Message-ID: <20170731221719.16695-6-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

phy_ethtool_get_eee is already called by the DSA layer, thus remove the
duplicated call in the qca8k driver. qca8k_get_eee becomes unnecessary.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/qca8k.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index c316c55aabc6..b5f2710064e5 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -691,22 +691,6 @@ qca8k_set_eee(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int
-qca8k_get_eee(struct dsa_switch *ds, int port,
-	      struct ethtool_eee *e)
-{
-	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
-	struct net_device *netdev = ds->ports[port].netdev;
-	int ret;
-
-	ret = phy_ethtool_get_eee(netdev->phydev, p);
-	e->eee_active = p->eee_active;
-	e->eee_enabled = p->eee_enabled;
-
-	return ret;
-}
-
 static void
 qca8k_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
 {
@@ -906,7 +890,6 @@ static const struct dsa_switch_ops qca8k_switch_ops = {
 	.phy_write		= qca8k_phy_write,
 	.get_ethtool_stats	= qca8k_get_ethtool_stats,
 	.get_sset_count		= qca8k_get_sset_count,
-	.get_eee		= qca8k_get_eee,
 	.set_eee		= qca8k_set_eee,
 	.port_enable		= qca8k_port_enable,
 	.port_disable		= qca8k_port_disable,
-- 
2.13.3
