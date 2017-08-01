From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 05/11] net: dsa: qca8k: empty qca8k_get_eee
Date: Tue,  1 Aug 2017 16:32:35 -0400
Message-ID: <20170801203241.22294-6-vivien.didelot@savoirfairelinux.com>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

phy_ethtool_get_eee is already called by the DSA layer, thus remove the
duplicated call in the qca8k driver.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/qca8k.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index c316c55aabc6..8cd4634c6985 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -695,16 +695,8 @@ static int
 qca8k_get_eee(struct dsa_switch *ds, int port,
 	      struct ethtool_eee *e)
 {
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
+	/* Nothing to do on the port's MAC */
+	return 0;
 }
 
 static void
-- 
2.13.3
