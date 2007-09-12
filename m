From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 build problem
Date: Wed, 12 Sep 2007 07:18:47 -0700 (PDT)
Message-ID: <20070912.071847.10311963.davem@davemloft.net>
References: <20070912160833.73af789d@oldman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:59595
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S968692AbXILOSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 10:18:50 -0400
In-Reply-To: <20070912160833.73af789d@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 12 Sep 2007 16:08:33 +0200

> ERROR: "xfrm_audit_state_delete" [net/key/af_key.ko] undefined!
> ERROR: "xfrm_audit_state_add" [net/key/af_key.ko] undefined!
> ERROR: "xfrm_audit_policy_add" [net/key/af_key.ko] undefined!
> ERROR: "xfrm_audit_policy_delete" [net/key/af_key.ko] undefined

I just checked in the following fix for this:

>From 2c2d4ef06a1bdb25b721372ab63adde1523e34ec Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@kimchee.(none)>
Date: Wed, 12 Sep 2007 16:17:36 +0200
Subject: [PATCH] [XFRM]: Add missing auditing symbol exports.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 ++
 net/xfrm/xfrm_state.c  |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index de0ff51..50682d3 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2341,6 +2341,7 @@ xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
 void
 xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
@@ -2357,6 +2358,7 @@ xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL_GPL(xfrm_audit_policy_delete);
 #endif
 
 #ifdef CONFIG_XFRM_MIGRATE
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f64621c..15734ad 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1865,6 +1865,7 @@ xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
 			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
 void
 xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
@@ -1883,4 +1884,5 @@ xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
 			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL_GPL(xfrm_audit_state_delete);
 #endif /* CONFIG_AUDITSYSCALL */
-- 
1.5.2.4

