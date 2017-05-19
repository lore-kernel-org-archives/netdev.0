From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 16/20] net: dsa: move notifier info to private header
Date: Fri, 19 May 2017 17:00:51 -0400
Message-ID: <20170519210055.9366-17-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA notifier events and info structure definitions are not meant for
DSA drivers and users, but only used internally by the DSA core files.

Move them from the public net/dsa.h file to the private dsa_priv.h file.

Also use this opportunity to turn the events into an anonymous enum,
because we don't care about the values, and this will prevent future
conflicts when adding (and sorting) new events.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  | 10 ----------
 net/dsa/dsa_priv.h | 12 ++++++++++++
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 791fed62fb16..c0e567c0c824 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -285,16 +285,6 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 		return ds->rtable[dst->cpu_dp->ds->index];
 }
 
-#define DSA_NOTIFIER_BRIDGE_JOIN		1
-#define DSA_NOTIFIER_BRIDGE_LEAVE		2
-
-/* DSA_NOTIFIER_BRIDGE_* */
-struct dsa_notifier_bridge_info {
-	struct net_device *br;
-	int sw_index;
-	int port;
-};
-
 struct dsa_switch_ops {
 	/*
 	 * Legacy probing.
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 16021a891095..c19241eb094b 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -16,6 +16,18 @@
 #include <linux/netpoll.h>
 #include <net/dsa.h>
 
+enum {
+	DSA_NOTIFIER_BRIDGE_JOIN,
+	DSA_NOTIFIER_BRIDGE_LEAVE,
+};
+
+/* DSA_NOTIFIER_BRIDGE_* */
+struct dsa_notifier_bridge_info {
+	struct net_device *br;
+	int sw_index;
+	int port;
+};
+
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
 	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
-- 
2.13.0
