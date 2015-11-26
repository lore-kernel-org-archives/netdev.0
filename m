From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/7] net: ipmr: move struct mr_table and VIF_EXISTS to mroute.h
Date: Thu, 26 Nov 2015 15:23:47 +0100
Message-ID: <1448547830-21716-5-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36647 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbbKZOYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:05 -0500
Received: by wmww144 with SMTP id w144so23482913wmw.1
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:05 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Move the definitions of VIF_EXISTS() and struct mr_table to mroute.h

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/mroute.h | 21 +++++++++++++++++++--
 net/ipv4/ipmr.c        | 18 ------------------
 2 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 7c567a2679ce..bf9b322cb0b0 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -59,6 +59,25 @@ struct vif_device {
 
 #define VIFF_STATIC 0x8000
 
+#define VIF_EXISTS(_mrt, _idx) ((_mrt)->vif_table[_idx].dev != NULL)
+#define MFC_LINES 64
+
+struct mr_table {
+	struct list_head	list;
+	possible_net_t		net;
+	u32			id;
+	struct sock __rcu	*mroute_sk;
+	struct timer_list	ipmr_expire_timer;
+	struct list_head	mfc_unres_queue;
+	struct list_head	mfc_cache_array[MFC_LINES];
+	struct vif_device	vif_table[MAXVIFS];
+	int			maxvif;
+	atomic_t		cache_resolve_queue_len;
+	bool			mroute_do_assert;
+	bool			mroute_do_pim;
+	int			mroute_reg_vif_num;
+};
+
 /* mfc_flags:
  * MFC_STATIC - the entry was added statically (not by a routing daemon)
  */
@@ -91,8 +110,6 @@ struct mfc_cache {
 	struct rcu_head	rcu;
 };
 
-#define MFC_LINES 64
-
 #ifdef __BIG_ENDIAN
 #define MFC_HASH(a,b)	(((((__force u32)(__be32)a)>>24)^(((__force u32)(__be32)b)>>26))&(MFC_LINES-1))
 #else
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a74e61883b8f..ff3dbbb9f11c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -67,22 +67,6 @@
 #include <net/fib_rules.h>
 #include <linux/netconf.h>
 
-struct mr_table {
-	struct list_head	list;
-	possible_net_t		net;
-	u32			id;
-	struct sock __rcu	*mroute_sk;
-	struct timer_list	ipmr_expire_timer;
-	struct list_head	mfc_unres_queue;
-	struct list_head	mfc_cache_array[MFC_LINES];
-	struct vif_device	vif_table[MAXVIFS];
-	int			maxvif;
-	atomic_t		cache_resolve_queue_len;
-	bool			mroute_do_assert;
-	bool			mroute_do_pim;
-	int			mroute_reg_vif_num;
-};
-
 struct ipmr_rule {
 	struct fib_rule		common;
 };
@@ -104,8 +88,6 @@ static DEFINE_RWLOCK(mrt_lock);
 
 /* Multicast router control variables */
 
-#define VIF_EXISTS(_mrt, _idx) ((_mrt)->vif_table[_idx].dev != NULL)
-
 /* Special spinlock for queue of unresolved entries */
 static DEFINE_SPINLOCK(mfc_unres_lock);
 
-- 
2.4.3
