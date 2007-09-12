From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][XFRM][patch 1/1] fix xfrm audit export symbol for allmodconfig
Date: Wed, 12 Sep 2007 17:27:16 +0200
Message-ID: <20070912153708.030162683@mai.toulouse-stg.fr.ibm.com>
References: <20070912152715.747974665@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, Joy Latten <latten@austin.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:39750 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758165AbXILPjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 11:39:22 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8CFdLb8082422
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:39:21 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CFdKvM3022944
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 16:39:20 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CFd7kh029685
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 16:39:07 +0100
Content-Disposition: inline; filename=net-fix-xfrm-audit-syscall-export-symbol.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

This patch fixes export symbol for:
	xfrm_audit_policy_add
	xfrm_audit_policy_delete
	xfrm_audit_state_add
	xfrm_audit_state_delete
That allows xfrm_user and af_key to be compiled as module

I didn't used EXPORT_SYMBOL_GPL to be consistent with the rest
of the code.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/xfrm/xfrm_policy.c |    2 ++
 net/xfrm/xfrm_state.c  |    3 +++
 2 files changed, 5 insertions(+)

Index: net-2.6.24/net/xfrm/xfrm_policy.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_policy.c
+++ net-2.6.24/net/xfrm/xfrm_policy.c
@@ -2341,6 +2341,7 @@
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL(xfrm_audit_policy_add);
 
 void
 xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
@@ -2357,6 +2358,7 @@
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL(xfrm_audit_policy_delete);
 #endif
 
 #ifdef CONFIG_XFRM_MIGRATE
Index: net-2.6.24/net/xfrm/xfrm_state.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_state.c
+++ net-2.6.24/net/xfrm/xfrm_state.c
@@ -1865,6 +1865,7 @@
 			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL(xfrm_audit_state_add);
 
 void
 xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
@@ -1883,4 +1884,6 @@
 			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
 	audit_log_end(audit_buf);
 }
+EXPORT_SYMBOL(xfrm_audit_state_delete);
+
 #endif /* CONFIG_AUDITSYSCALL */

-- 
