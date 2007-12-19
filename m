From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] XFRM: Audit function arguments misordered
Date: Wed, 19 Dec 2007 14:29:38 -0500
Message-ID: <20071219192937.15561.52837.stgit@flek.americas.hpqcorp.net>
References: <20071219192309.15561.9843.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:4632 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbXLSTbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 14:31:41 -0500
In-Reply-To: <20071219192309.15561.9843.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In several places the arguments to the xfrm_audit_start() function are in the
wrong order resulting in incorrect user information being reported.  This
patch corrects this by pacing the arguments in the correct order.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/xfrm/xfrm_policy.c |    4 ++--
 net/xfrm/xfrm_state.c  |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b91b166..26b846e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2162,7 +2162,7 @@ xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(auid, sid);
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SPD-add res=%u", result);
@@ -2179,7 +2179,7 @@ xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(auid, sid);
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SPD-delete res=%u", result);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1af522b..ee1e697 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2033,7 +2033,7 @@ xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(auid, sid);
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SAD-add res=%u",result);
@@ -2053,7 +2053,7 @@ xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
 
 	if (audit_enabled == 0)
 		return;
-	audit_buf = xfrm_audit_start(sid, auid);
+	audit_buf = xfrm_audit_start(auid, sid);
 	if (audit_buf == NULL)
 		return;
 	audit_log_format(audit_buf, " op=SAD-delete res=%u",result);

