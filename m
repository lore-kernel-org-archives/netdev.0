From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/21] net/atm/atm_misc.c: checkpatch cleanups
Date: Tue, 26 Jan 2010 13:40:02 -0800
Message-ID: <766050b3d18475084646fe8ce9356f1ff3011997.1264541548.git.joe@perches.com>
References: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1475 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab0AZVkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:22 -0500
In-Reply-To: <cover.1264541547.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moved EXPORT_SYMBOL to follow definition
Add space after commas

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/atm_misc.c |   40 ++++++++++++++++------------------------
 1 files changed, 16 insertions(+), 24 deletions(-)

diff --git a/net/atm/atm_misc.c b/net/atm/atm_misc.c
index 02cc7e7..fc63526 100644
--- a/net/atm/atm_misc.c
+++ b/net/atm/atm_misc.c
@@ -2,37 +2,35 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL ICA */
 
-
 #include <linux/module.h>
 #include <linux/atm.h>
 #include <linux/atmdev.h>
 #include <linux/skbuff.h>
 #include <linux/sonet.h>
 #include <linux/bitops.h>
+#include <linux/errno.h>
 #include <asm/atomic.h>
-#include <asm/errno.h>
-
 
-int atm_charge(struct atm_vcc *vcc,int truesize)
+int atm_charge(struct atm_vcc *vcc, int truesize)
 {
-	atm_force_charge(vcc,truesize);
+	atm_force_charge(vcc, truesize);
 	if (atomic_read(&sk_atm(vcc)->sk_rmem_alloc) <= sk_atm(vcc)->sk_rcvbuf)
 		return 1;
-	atm_return(vcc,truesize);
+	atm_return(vcc, truesize);
 	atomic_inc(&vcc->stats->rx_drop);
 	return 0;
 }
+EXPORT_SYMBOL(atm_charge);
 
-
-struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc,int pdu_size,
-    gfp_t gfp_flags)
+struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc, int pdu_size,
+				 gfp_t gfp_flags)
 {
 	struct sock *sk = sk_atm(vcc);
 	int guess = atm_guess_pdu2truesize(pdu_size);
 
-	atm_force_charge(vcc,guess);
+	atm_force_charge(vcc, guess);
 	if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf) {
-		struct sk_buff *skb = alloc_skb(pdu_size,gfp_flags);
+		struct sk_buff *skb = alloc_skb(pdu_size, gfp_flags);
 
 		if (skb) {
 			atomic_add(skb->truesize-guess,
@@ -40,10 +38,11 @@ struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc,int pdu_size,
 			return skb;
 		}
 	}
-	atm_return(vcc,guess);
+	atm_return(vcc, guess);
 	atomic_inc(&vcc->stats->rx_drop);
 	return NULL;
 }
+EXPORT_SYMBOL(atm_alloc_charge);
 
 
 /*
@@ -73,7 +72,6 @@ struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc,int pdu_size,
  *	 else *
  */
 
-
 int atm_pcr_goal(const struct atm_trafprm *tp)
 {
 	if (tp->pcr && tp->pcr != ATM_MAX_PCR)
@@ -84,26 +82,20 @@ int atm_pcr_goal(const struct atm_trafprm *tp)
 		return -tp->max_pcr;
 	return 0;
 }
+EXPORT_SYMBOL(atm_pcr_goal);
 
-
-void sonet_copy_stats(struct k_sonet_stats *from,struct sonet_stats *to)
+void sonet_copy_stats(struct k_sonet_stats *from, struct sonet_stats *to)
 {
 #define __HANDLE_ITEM(i) to->i = atomic_read(&from->i)
 	__SONET_ITEMS
 #undef __HANDLE_ITEM
 }
+EXPORT_SYMBOL(sonet_copy_stats);
 
-
-void sonet_subtract_stats(struct k_sonet_stats *from,struct sonet_stats *to)
+void sonet_subtract_stats(struct k_sonet_stats *from, struct sonet_stats *to)
 {
-#define __HANDLE_ITEM(i) atomic_sub(to->i,&from->i)
+#define __HANDLE_ITEM(i) atomic_sub(to->i, &from->i)
 	__SONET_ITEMS
 #undef __HANDLE_ITEM
 }
-
-
-EXPORT_SYMBOL(atm_charge);
-EXPORT_SYMBOL(atm_alloc_charge);
-EXPORT_SYMBOL(atm_pcr_goal);
-EXPORT_SYMBOL(sonet_copy_stats);
 EXPORT_SYMBOL(sonet_subtract_stats);
-- 
1.6.6.rc0.57.gad7a

