From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] napi: use non-interruptible sleep in napi_disable
Date: Thu, 25 Oct 2007 13:59:08 +1000
Message-ID: <20071025035920.C2D39DDECE@ozlabs.org>
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52931 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758575AbXJYD7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 23:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current napi_disable() uses msleep_interruptible() but doesn't
(and can't) exit in case there's a signal, thus ending up doing a
hot spin without a cpu_relax. Use uninterruptible sleep instead.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-work/include/linux/netdevice.h
===================================================================
--- linux-work.orig/include/linux/netdevice.h	2007-10-17 12:39:16.000000000 +1000
+++ linux-work/include/linux/netdevice.h	2007-10-17 12:45:00.000000000 +1000
@@ -390,7 +390,7 @@ static inline void napi_complete(struct 
 static inline void napi_disable(struct napi_struct *n)
 {
 	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
-		msleep_interruptible(1);
+		msleep(1);
 }
 
 /**
