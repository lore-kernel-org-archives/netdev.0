From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 043/115] sysctl: remove .child from kernel/perfmon/ (ia64)
Date: Mon,  9 May 2011 00:38:55 +0200
Message-ID: <1304894407-32201-44-git-send-email-lucian.grijincu@gmail.com>
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
 arch/ia64/kernel/perfmon.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 89accc6..96743dd 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -552,22 +552,13 @@ static ctl_table pfm_ctl_table[]={
 	},
 	{}
 };
-static ctl_table pfm_sysctl_dir[] = {
-	{
-		.procname	= "perfmon",
-		.mode		= 0555,
-		.child		= pfm_ctl_table,
-	},
- 	{}
-};
-static ctl_table pfm_sysctl_root[] = {
-	{
-		.procname	= "kernel",
-		.mode		= 0555,
-		.child		= pfm_sysctl_dir,
-	},
- 	{}
+
+static const __initdata struct ctl_path pfm_path[] = {
+	{ .procname = "kernel" },
+	{ .procname = "perfmon" },
+	{ }
 };
+
 static struct ctl_table_header *pfm_sysctl_header;
 
 static int pfm_context_unload(pfm_context_t *ctx, void *arg, int count, struct pt_regs *regs);
@@ -6687,7 +6678,7 @@ pfm_init(void)
 	/*
 	 * create /proc/sys/kernel/perfmon (for debugging purposes)
 	 */
-	pfm_sysctl_header = register_sysctl_table(pfm_sysctl_root);
+	pfm_sysctl_header = register_sysctl_paths(pfm_path, pfm_ctl_table);
 
 	/*
 	 * initialize all our spinlocks
-- 
1.7.5.134.g1c08b
