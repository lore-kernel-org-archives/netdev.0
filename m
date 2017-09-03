From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net-next] bridge: switchdev: Use an helper to clear forward mark
Date: Sun,  3 Sep 2017 17:44:13 +0300
Message-ID: <20170903144413.21946-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, yotamg@mellanox.com,
        bridge@lists.linux-foundation.org, mlxsw@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0084.outbound.protection.outlook.com ([104.47.0.84]:43776
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752908AbdICOoy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 10:44:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using ifdef in the C file.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Suggested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Tested-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/bridge/br_device.c  | 4 +---
 net/bridge/br_private.h | 9 +++++++++
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5a7be3bddfa9..f6b6a92f1c48 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -53,9 +53,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
-#ifdef CONFIG_NET_SWITCHDEV
-	skb->offload_fwd_mark = 0;
-#endif
+	br_switchdev_frame_unmark(skb);
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fd9ee73e0a6d..e870cfc85b14 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -1091,6 +1091,11 @@ int br_switchdev_set_port_flag(struct net_bridge_port *p,
 			       unsigned long mask);
 void br_switchdev_fdb_notify(const struct net_bridge_fdb_entry *fdb,
 			     int type);
+
+static inline void br_switchdev_frame_unmark(struct sk_buff *skb)
+{
+	skb->offload_fwd_mark = 0;
+}
 #else
 static inline int nbp_switchdev_mark_set(struct net_bridge_port *p)
 {
@@ -1119,6 +1124,10 @@ static inline void
 br_switchdev_fdb_notify(const struct net_bridge_fdb_entry *fdb, int type)
 {
 }
+
+static inline void br_switchdev_frame_unmark(struct sk_buff *skb)
+{
+}
 #endif /* CONFIG_NET_SWITCHDEV */
 
 #endif
-- 
2.13.5
