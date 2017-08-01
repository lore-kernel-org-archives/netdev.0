From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 01/11] net: dsa: PHY device is mandatory for EEE
Date: Tue,  1 Aug 2017 16:32:31 -0400
Message-ID: <20170801203241.22294-2-vivien.didelot@savoirfairelinux.com>
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

The port's PHY and MAC are both implied in EEE. The current code does
not call the PHY operations if the related device is NULL. Change that
by returning -ENODEV if there's no PHY device attached to the interface.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9507bd38cf04..7df55d597740 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -648,6 +648,10 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	struct dsa_switch *ds = p->dp->ds;
 	int ret;
 
+	/* Port's PHY and MAC both need to be EEE capable */
+	if (!p->phy)
+		return -ENODEV;
+
 	if (!ds->ops->set_eee)
 		return -EOPNOTSUPP;
 
@@ -655,10 +659,7 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (ret)
 		return ret;
 
-	if (p->phy)
-		ret = phy_ethtool_set_eee(p->phy, e);
-
-	return ret;
+	return phy_ethtool_set_eee(p->phy, e);
 }
 
 static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
@@ -667,6 +668,10 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	struct dsa_switch *ds = p->dp->ds;
 	int ret;
 
+	/* Port's PHY and MAC both need to be EEE capable */
+	if (!p->phy)
+		return -ENODEV;
+
 	if (!ds->ops->get_eee)
 		return -EOPNOTSUPP;
 
@@ -674,10 +679,7 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (ret)
 		return ret;
 
-	if (p->phy)
-		ret = phy_ethtool_get_eee(p->phy, e);
-
-	return ret;
+	return phy_ethtool_get_eee(p->phy, e);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
2.13.3
