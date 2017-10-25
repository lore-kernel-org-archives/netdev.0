From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net-next] macvlan: remove unused fields in struct macvlan_dev
Date: Wed, 25 Oct 2017 12:26:43 -0700
Message-ID: <1508959603-29062-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
        sainath.grandhi@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48056 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdJYTtU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 15:49:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 635b8c8ecdd2 ("tap: Renaming tap related APIs, data structures,
macros") captured all the tap related fields into a new struct tap_dev.
However, it failed to remove those fields from struct macvlan_dev.
Those fields are currently unused and must be removed. While there
I moved the comment for MAX_TAP_QUEUES to the right place.

Fixes: 635b8c8ecdd27142 (tap: Renaming tap related APIs, data structures, macros)
Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 include/linux/if_macvlan.h | 15 ---------------
 include/linux/if_tap.h     |  4 ++++
 2 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 10e319f..e13b369 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -10,13 +10,6 @@
 #include <linux/u64_stats_sync.h>
 
 struct macvlan_port;
-struct macvtap_queue;
-
-/*
- * Maximum times a macvtap device can be opened. This can be used to
- * configure the number of receive queue, e.g. for multiqueue virtio.
- */
-#define MAX_TAP_QUEUES	256
 
 #define MACVLAN_MC_FILTER_BITS	8
 #define MACVLAN_MC_FILTER_SZ	(1 << MACVLAN_MC_FILTER_BITS)
@@ -35,14 +28,6 @@ struct macvlan_dev {
 	netdev_features_t	set_features;
 	enum macvlan_mode	mode;
 	u16			flags;
-	/* This array tracks active taps. */
-	struct tap_queue	__rcu *taps[MAX_TAP_QUEUES];
-	/* This list tracks all taps (both enabled and disabled) */
-	struct list_head	queue_list;
-	int			numvtaps;
-	int			numqueues;
-	netdev_features_t	tap_features;
-	int			minor;
 	int			nest_level;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll		*netpoll;
diff --git a/include/linux/if_tap.h b/include/linux/if_tap.h
index 4837157..d1b5173 100644
--- a/include/linux/if_tap.h
+++ b/include/linux/if_tap.h
@@ -22,6 +22,10 @@ static inline struct skb_array *tap_get_skb_array(struct file *f)
 #include <net/sock.h>
 #include <linux/skb_array.h>
 
+/*
+ * Maximum times a tap device can be opened. This can be used to
+ * configure the number of receive queue, e.g. for multiqueue virtio.
+ */
 #define MAX_TAP_QUEUES 256
 
 struct tap_queue;
-- 
1.8.3.1
