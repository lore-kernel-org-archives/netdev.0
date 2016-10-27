From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 07/17] batman-adv: Move batadv_sum_counter to soft-interface.c
Date: Thu, 27 Oct 2016 21:01:40 +0200
Message-ID: <20161027190150.7880-8-sw@simonwunderlich.de>
References: <20161027190150.7880-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38350 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941975AbcJ0TB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 15:01:57 -0400
In-Reply-To: <20161027190150.7880-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The function batadv_sum_counter is only used in soft-interface.c and has no
special relevance for main.h.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/main.h           | 21 ---------------------
 net/batman-adv/soft-interface.c | 21 +++++++++++++++++++++
 2 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8b0979b..6a2328d 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -185,7 +185,6 @@ enum batadv_uev_type {
 
 #include <linux/bitops.h> /* for packet.h */
 #include <linux/compiler.h>
-#include <linux/cpumask.h>
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h> /* for packet.h */
 #include <linux/if_vlan.h>
@@ -284,26 +283,6 @@ static inline void batadv_add_counter(struct batadv_priv *bat_priv, size_t idx,
 
 #define batadv_inc_counter(b, i) batadv_add_counter(b, i, 1)
 
-/**
- * batadv_sum_counter - Sum the cpu-local counters for index 'idx'
- * @bat_priv: the bat priv with all the soft interface information
- * @idx: index of counter to sum up
- *
- * Return: sum of all cpu-local counters
- */
-static inline u64 batadv_sum_counter(struct batadv_priv *bat_priv,  size_t idx)
-{
-	u64 *counters, sum = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		counters = per_cpu_ptr(bat_priv->bat_counters, cpu);
-		sum += counters[idx];
-	}
-
-	return sum;
-}
-
 /* Define a macro to reach the control buffer of the skb. The members of the
  * control buffer are defined in struct batadv_skb_cb in types.h.
  * The macro is inspired by the similar macro TCP_SKB_CB() in tcp.h.
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 49e16b6..f37c1c7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -22,6 +22,7 @@
 #include <linux/byteorder/generic.h>
 #include <linux/cache.h>
 #include <linux/compiler.h>
+#include <linux/cpumask.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -116,6 +117,26 @@ static int batadv_interface_release(struct net_device *dev)
 	return 0;
 }
 
+/**
+ * batadv_sum_counter - Sum the cpu-local counters for index 'idx'
+ * @bat_priv: the bat priv with all the soft interface information
+ * @idx: index of counter to sum up
+ *
+ * Return: sum of all cpu-local counters
+ */
+static u64 batadv_sum_counter(struct batadv_priv *bat_priv,  size_t idx)
+{
+	u64 *counters, sum = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		counters = per_cpu_ptr(bat_priv->bat_counters, cpu);
+		sum += counters[idx];
+	}
+
+	return sum;
+}
+
 static struct net_device_stats *batadv_interface_stats(struct net_device *dev)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
-- 
2.10.1
