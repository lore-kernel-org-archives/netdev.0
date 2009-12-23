From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2 9/9] llc: remove unused APIs (which should be private anyway)
Date: Thu, 24 Dec 2009 01:45:34 +0200
Message-ID: <1261611934-24348-10-git-send-email-opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757544AbZLWXtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:49:13 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the list & lock from the exported API - it is not used anywhere
in the tree and most operations should be covered by llc_sap_open(),
llc_sap_close() and llc_sap_find().

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/llc.h  |    1 -
 net/llc/llc_core.c |    4 +---
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index aee826d..7b9528b 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -92,7 +92,6 @@ struct hlist_nulls_head *llc_sk_laddr_hash(struct llc_sap *sap,
 #define LLC_DEST_CONN            2      /* Type 2 goes here */
 
 extern struct list_head llc_sap_list;
-extern spinlock_t llc_sap_list_lock;
 
 extern int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev);
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 21fe87e..3f4e85b 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -23,7 +23,7 @@
 #include <net/llc.h>
 
 LIST_HEAD(llc_sap_list);
-DEFINE_SPINLOCK(llc_sap_list_lock);
+static DEFINE_SPINLOCK(llc_sap_list_lock);
 
 /**
  *	llc_sap_alloc - allocates and initializes sap.
@@ -160,8 +160,6 @@ static void __exit llc_exit(void)
 module_init(llc_init);
 module_exit(llc_exit);
 
-EXPORT_SYMBOL(llc_sap_list);
-EXPORT_SYMBOL(llc_sap_list_lock);
 EXPORT_SYMBOL(llc_sap_find);
 EXPORT_SYMBOL(llc_sap_open);
 EXPORT_SYMBOL(llc_sap_close);
-- 
1.5.6.5

