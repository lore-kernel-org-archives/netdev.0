From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 48/48] Audit: allow root user of un-init user namespace to set audit
Date: Tue, 7 May 2013 10:21:09 +0800
Message-ID: <1367893269-9308-49-git-send-email-gaofeng@cn.fujitsu.com>
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

This patch reduce the permission check of setting audit.
We already finish the user namespace support for audit,
now we can allow the root user of uninit userns to set
and use the audit subsystem.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 kernel/audit.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 59e5cca..8a27197 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -571,11 +571,6 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 {
 	int err = 0;
 
-	/* Only support the initial namespaces for now. */
-	if ((current_user_ns() != &init_user_ns) ||
-	    (task_active_pid_ns(current) != &init_pid_ns))
-		return -EPERM;
-
 	switch (msg_type) {
 	case AUDIT_GET:
 	case AUDIT_LIST:
@@ -590,13 +585,13 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 	case AUDIT_TTY_SET:
 	case AUDIT_TRIM:
 	case AUDIT_MAKE_EQUIV:
-		if (!capable(CAP_AUDIT_CONTROL))
+		if (!ns_capable(current_user_ns(), CAP_AUDIT_CONTROL))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
 	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
 	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
-		if (!capable(CAP_AUDIT_WRITE))
+		if (!ns_capable(current_user_ns(), CAP_AUDIT_WRITE))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
-- 
1.8.1.4
