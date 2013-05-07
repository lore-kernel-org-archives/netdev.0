From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 38/48] Audit: tty: translate audit_log_start to audit_log_start_ns
Date: Tue, 7 May 2013 10:20:59 +0800
Message-ID: <1367893269-9308-39-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:16239 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S933302Ab3EGCTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 22:19:33 -0400
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can log audit message in the user namespace which current
task belongs to.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/tty/tty_audit.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/tty/tty_audit.c b/drivers/tty/tty_audit.c
index 6953dc8..b20ef14 100644
--- a/drivers/tty/tty_audit.c
+++ b/drivers/tty/tty_audit.c
@@ -65,8 +65,9 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
 			  int minor, unsigned char *data, size_t size)
 {
 	struct audit_buffer *ab;
+	struct user_namespace *ns = task_cred_xxx(tsk, user_ns);
 
-	ab = audit_log_start(NULL, GFP_KERNEL, AUDIT_TTY);
+	ab = audit_log_start_ns(ns, NULL, GFP_KERNEL, AUDIT_TTY);
 	if (ab) {
 		char name[sizeof(tsk->comm)];
 		kuid_t uid = task_uid(tsk);
@@ -82,7 +83,7 @@ static void tty_audit_log(const char *description, struct task_struct *tsk,
 		audit_log_untrustedstring(ab, name);
 		audit_log_format(ab, " data=");
 		audit_log_n_hex(ab, data, size);
-		audit_log_end(ab);
+		audit_log_end_ns(ns, ab);
 	}
 }
 
-- 
1.8.1.4
