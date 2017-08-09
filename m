From: John Crispin <john@phrozen.org>
Subject: [PATCH 1/4] net-next: dsa: move struct dsa_device_ops to the global header file
Date: Wed,  9 Aug 2017 14:41:16 +0200
Message-ID: <20170809124119.24320-2-john@phrozen.org>
References: <20170809124119.24320-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        linux-kernel@vger.kernel.org, Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        John Crispin <john@phrozen.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:37810 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751523AbdHIMmK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 08:42:10 -0400
In-Reply-To: <20170809124119.24320-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to access this struct from within the flow_dissector to fix
dissection for packets coming in on DSA devices.

Signed-off-by: Muciri Gatimu <muciri@openmesh.com>
Signed-off-by: Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>
Signed-off-by: John Crispin <john@phrozen.org>
---
 include/net/dsa.h  | 7 +++++++
 net/dsa/dsa_priv.h | 7 -------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index a4f66dbb4b7c..65d7804c6f69 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -101,6 +101,13 @@ struct dsa_platform_data {
 
 struct packet_type;
 
+struct dsa_device_ops {
+	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
+	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt,
+			       struct net_device *orig_dev);
+};
+
 struct dsa_switch_tree {
 	struct list_head	list;
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 68c63d4b989c..9fff7f4c8689 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -65,13 +65,6 @@ struct dsa_notifier_vlan_info {
 	int port;
 };
 
-struct dsa_device_ops {
-	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
-	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt,
-			       struct net_device *orig_dev);
-};
-
 struct dsa_slave_priv {
 	/* Copy of dp->ds->dst->tag_ops->xmit for faster access in hot path */
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
-- 
2.11.0
