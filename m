From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 044/115] sysctl: remove .child from kernel/ (ia64/kdump)
Date: Mon,  9 May 2011 00:38:56 +0200
Message-ID: <1304894407-32201-45-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 arch/ia64/kernel/crash.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index b942f40..e54aea5 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -255,17 +255,14 @@ static ctl_table kdump_ctl_table[] = {
 	{ }
 };
 
-static ctl_table sys_table[] = {
-	{
-	  .procname = "kernel",
-	  .mode = 0555,
-	  .child = kdump_ctl_table,
-	},
+static const __initdata struct ctl_path kdump_path[] = {
+	{ .procname = "kernel" },
 	{ }
 };
+
 #endif
 
-static int
+static __init int
 machine_crash_setup(void)
 {
 	/* be notified before default_monarch_init_process */
@@ -277,7 +274,7 @@ machine_crash_setup(void)
 	if((ret = register_die_notifier(&kdump_init_notifier_nb)) != 0)
 		return ret;
 #ifdef CONFIG_SYSCTL
-	register_sysctl_table(sys_table);
+	register_sysctl_paths(kdump_path, kdump_ctl_table);
 #endif
 	return 0;
 }
-- 
1.7.5.134.g1c08b
