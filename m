From: chavey@google.com
Subject: [PATCH 1/1] fix net/core/dst.c coding style error and warnings
Date: Mon, 29 Mar 2010 13:41:36 -0700
Message-ID: <pvmzl1qoo73.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:26145 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952Ab0C2Ulp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 16:41:45 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o2TKfhNv018134
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 13:41:44 -0700
Received: from bwz3 (bwz3.prod.google.com [10.188.26.3])
	by kpbe17.cbf.corp.google.com with ESMTP id o2TKfF4x029956
	for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 13:41:42 -0700
Received: by bwz3 with SMTP id 3so643946bwz.31
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 13:41:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix coding style errors and warnings output while running checkpatch.pl
on the file net/core/dst.c.

Signed-off-by: chavey <chavey@google.com>
---
 net/core/dst.c |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index cb1b348..2076d84 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -43,7 +43,7 @@ static atomic_t			 dst_total = ATOMIC_INIT(0);
  */
 static struct {
 	spinlock_t		lock;
-	struct dst_entry 	*list;
+	struct dst_entry	*list;
 	unsigned long		timer_inc;
 	unsigned long		timer_expires;
 } dst_garbage = {
@@ -51,7 +51,7 @@ static struct {
 	.timer_inc = DST_GC_MAX,
 };
 static void dst_gc_task(struct work_struct *work);
-static void ___dst_free(struct dst_entry * dst);
+static void ___dst_free(struct dst_entry *dst);
 
 static DECLARE_DELAYED_WORK(dst_gc_work, dst_gc_task);
 
@@ -135,8 +135,8 @@ loop:
 		}
 		expires = dst_garbage.timer_expires;
 		/*
-		 * if the next desired timer is more than 4 seconds in the future
-		 * then round the timer to whole seconds
+		 * if the next desired timer is more than 4 seconds in the
+		 * future then round the timer to whole seconds
 		 */
 		if (expires > 4*HZ)
 			expires = round_jiffies_relative(expires);
@@ -151,7 +151,8 @@ loop:
 		" expires: %lu elapsed: %lu us\n",
 		atomic_read(&dst_total), delayed, work_performed,
 		expires,
-		elapsed.tv_sec * USEC_PER_SEC + elapsed.tv_nsec / NSEC_PER_USEC);
+		elapsed.tv_sec * USEC_PER_SEC +
+		  elapsed.tv_nsec / NSEC_PER_USEC);
 #endif
 }
 
@@ -162,9 +163,9 @@ int dst_discard(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(dst_discard);
 
-void * dst_alloc(struct dst_ops * ops)
+void *dst_alloc(struct dst_ops *ops)
 {
-	struct dst_entry * dst;
+	struct dst_entry *dst;
 
 	if (ops->gc && atomic_read(&ops->entries) > ops->gc_thresh) {
 		if (ops->gc(ops))
@@ -184,19 +185,20 @@ void * dst_alloc(struct dst_ops * ops)
 	atomic_inc(&ops->entries);
 	return dst;
 }
+EXPORT_SYMBOL(dst_alloc);
 
-static void ___dst_free(struct dst_entry * dst)
+static void ___dst_free(struct dst_entry *dst)
 {
 	/* The first case (dev==NULL) is required, when
 	   protocol module is unloaded.
 	 */
-	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
+	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP))
 		dst->input = dst->output = dst_discard;
-	}
 	dst->obsolete = 2;
 }
+EXPORT_SYMBOL(__dst_free);
 
-void __dst_free(struct dst_entry * dst)
+void __dst_free(struct dst_entry *dst)
 {
 	spin_lock_bh(&dst_garbage.lock);
 	___dst_free(dst);
@@ -261,15 +263,16 @@ again:
 	}
 	return NULL;
 }
+EXPORT_SYMBOL(dst_destroy);
 
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
-               int newrefcnt;
+		int newrefcnt;
 
 		smp_mb__before_atomic_dec();
-               newrefcnt = atomic_dec_return(&dst->__refcnt);
-               WARN_ON(newrefcnt < 0);
+		newrefcnt = atomic_dec_return(&dst->__refcnt);
+		WARN_ON(newrefcnt < 0);
 	}
 }
 EXPORT_SYMBOL(dst_release);
@@ -305,7 +308,8 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 	}
 }
 
-static int dst_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
+static int dst_dev_event(struct notifier_block *this, unsigned long event,
+			 void *ptr)
 {
 	struct net_device *dev = ptr;
 	struct dst_entry *dst, *last = NULL;
@@ -328,9 +332,8 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event, void
 			last->next = dst;
 		else
 			dst_busy_list = dst;
-		for (; dst; dst = dst->next) {
+		for (; dst; dst = dst->next)
 			dst_ifdown(dst, dev, event != NETDEV_DOWN);
-		}
 		mutex_unlock(&dst_gc_mutex);
 		break;
 	}
@@ -345,7 +348,3 @@ void __init dst_init(void)
 {
 	register_netdevice_notifier(&dst_dev_notifier);
 }
-
-EXPORT_SYMBOL(__dst_free);
-EXPORT_SYMBOL(dst_alloc);
-EXPORT_SYMBOL(dst_destroy);
-- 
1.7.0.1

