From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH RFC 3/3] net: dsa: remove dsa_slave_stp_update
Date: Fri, 12 Feb 2016 16:34:20 -0500
Message-ID: <1455312860-24666-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a port leaves a bridge, the bridge layer now restores its STP state
to Forwarding, if the device belong to a switchdev user.

Thus remove this redundant action from the DSA layer.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 40b9ca7..2b3774e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -410,18 +410,6 @@ static u32 dsa_slave_br_port_mask(struct dsa_switch *ds,
 	return mask;
 }
 
-static int dsa_slave_stp_update(struct net_device *dev, u8 state)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
-
-	if (ds->drv->port_stp_update)
-		ret = ds->drv->port_stp_update(ds, p->port, state);
-
-	return ret;
-}
-
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
@@ -552,11 +540,6 @@ static int dsa_slave_bridge_port_leave(struct net_device *dev)
 
 	p->bridge_dev = NULL;
 
-	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
-	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
-	 */
-	dsa_slave_stp_update(dev, BR_STATE_FORWARDING);
-
 	return ret;
 }
 
-- 
2.7.1
