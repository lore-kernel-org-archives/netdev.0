From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/6] net: bridge: get msgtype from nlmsghdr in mdb ops
Date: Wed, 17 May 2017 17:27:08 -0400
Message-ID: <20170517212709.6473-6-vivien.didelot@savoirfairelinux.com>
References: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org (moderated list:ETHERNET BRIDGE)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Retrieve the message type from the nlmsghdr structure instead of
hardcoding it in both br_mdb_add and br_mdb_del.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_mdb.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index a72d5e6f339f..d280b20587cb 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -569,6 +569,7 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net_bridge_port *p;
 	struct net_bridge_vlan *v;
 	struct net_bridge *br;
+	int msgtype = nlh->nlmsg_type;
 	int err;
 
 	err = br_mdb_parse(skb, nlh, &dev, &entry);
@@ -595,12 +596,12 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
-			err = __br_mdb_do(p, entry, RTM_NEWMDB);
+			err = __br_mdb_do(p, entry, msgtype);
 			if (err)
 				break;
 		}
 	} else {
-		err = __br_mdb_do(p, entry, RTM_NEWMDB);
+		err = __br_mdb_do(p, entry, msgtype);
 	}
 
 	return err;
@@ -677,6 +678,7 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net_bridge_port *p;
 	struct net_bridge_vlan *v;
 	struct net_bridge *br;
+	int msgtype = nlh->nlmsg_type;
 	int err;
 
 	err = br_mdb_parse(skb, nlh, &dev, &entry);
@@ -703,12 +705,12 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
-			err = __br_mdb_do(p, entry, RTM_DELMDB);
+			err = __br_mdb_do(p, entry, msgtype);
 			if (err)
 				break;
 		}
 	} else {
-		err = __br_mdb_do(p, entry, RTM_DELMDB);
+		err = __br_mdb_do(p, entry, msgtype);
 	}
 
 	return err;
-- 
2.13.0
