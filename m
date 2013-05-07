From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 41/48] Audit: lsm: translate audit_log_start to audit_log_start_ns
Date: Tue, 7 May 2013 10:21:02 +0800
Message-ID: <1367893269-9308-42-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now we can log audit message in the user namespace which current
task belongs to.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 security/lsm_audit.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/security/lsm_audit.c b/security/lsm_audit.c
index 8d8d97d..90fcd08 100644
--- a/security/lsm_audit.c
+++ b/security/lsm_audit.c
@@ -392,11 +392,15 @@ void common_lsm_audit(struct common_audit_data *a,
 	void (*post_audit)(struct audit_buffer *, void *))
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns;
 
 	if (a == NULL)
 		return;
+
+	ns = current_user_ns();
 	/* we use GFP_ATOMIC so we won't sleep */
-	ab = audit_log_start(current->audit_context, GFP_ATOMIC, AUDIT_AVC);
+	ab = audit_log_start_ns(ns, current->audit_context,
+				GFP_ATOMIC, AUDIT_AVC);
 
 	if (ab == NULL)
 		return;
@@ -409,5 +413,5 @@ void common_lsm_audit(struct common_audit_data *a,
 	if (post_audit)
 		post_audit(ab, a);
 
-	audit_log_end(ab);
+	audit_log_end_ns(ns, ab);
 }
-- 
1.8.1.4
