From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 7/8] net: switchdev: support static FDB addresses
Date: Mon, 10 Aug 2015 09:09:52 -0400
Message-ID: <1439212193-7673-8-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439212193-7673-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds an ndm_state member to the switchdev_obj_fdb structure,
in order to support static FDB addresses.

Set Rocker ndm_state to NUD_REACHABLE.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c | 1 +
 include/net/switchdev.h              | 1 +
 net/switchdev/switchdev.c            | 2 +-
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index b77e0e7..af05075 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4544,6 +4544,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 		if (found->key.pport != rocker_port->pport)
 			continue;
 		fdb->addr = found->key.addr;
+		fdb->ndm_state = NUD_REACHABLE;
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
 		err = obj->cb(rocker_port->dev, obj);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 89da893..319baab 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -72,6 +72,7 @@ struct switchdev_obj {
 		struct switchdev_obj_fdb {		/* PORT_FDB */
 			const unsigned char *addr;
 			u16 vid;
+			u16 ndm_state;
 		} fdb;
 	} u;
 };
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 33bafa2..16c1c43 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -810,7 +810,7 @@ static int switchdev_port_fdb_dump_cb(struct net_device *dev,
 	ndm->ndm_flags   = NTF_SELF;
 	ndm->ndm_type    = 0;
 	ndm->ndm_ifindex = dev->ifindex;
-	ndm->ndm_state   = NUD_REACHABLE;
+	ndm->ndm_state   = obj->u.fdb.ndm_state;
 
 	if (nla_put(dump->skb, NDA_LLADDR, ETH_ALEN, obj->u.fdb.addr))
 		goto nla_put_failure;
-- 
2.5.0
