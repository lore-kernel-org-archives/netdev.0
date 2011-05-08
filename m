From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 006/115] sysctl: remove .child from kernel/vsyscall64 (x86)
Date: Mon,  9 May 2011 00:38:18 +0200
Message-ID: <1304894407-32201-7-git-send-email-lucian.grijincu@gmail.com>
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
 arch/x86/kernel/vsyscall_64.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/arch/x86/kernel/vsyscall_64.c b/arch/x86/kernel/vsyscall_64.c
index dcbb28c..7d8b83d 100644
--- a/arch/x86/kernel/vsyscall_64.c
+++ b/arch/x86/kernel/vsyscall_64.c
@@ -234,18 +234,21 @@ static long __vsyscall(3) venosys_1(void)
 }
 
 #ifdef CONFIG_SYSCTL
-static ctl_table kernel_table2[] = {
-	{ .procname = "vsyscall64",
-	  .data = &vsyscall_gtod_data.sysctl_enabled, .maxlen = sizeof(int),
-	  .mode = 0644,
-	  .proc_handler = proc_dointvec },
-	{}
+static ctl_table vsyscall64_table[] = {
+	{
+		.procname = "vsyscall64",
+		.data     = &vsyscall_gtod_data.sysctl_enabled,
+		.maxlen   = sizeof(int),
+		.mode     = 0644,
+		.proc_handler = proc_dointvec,
+	},
+	{ }
 };
 
-static ctl_table kernel_root_table2[] = {
-	{ .procname = "kernel", .mode = 0555,
-	  .child = kernel_table2 },
-	{}
+
+static struct ctl_path kernel_root_path[] = {
+	{ .procname = "kernel" },
+	{ }
 };
 #endif
 
@@ -303,7 +306,7 @@ static int __init vsyscall_init(void)
 	BUG_ON((VSYSCALL_ADDR(0) != __fix_to_virt(VSYSCALL_FIRST_PAGE)));
 	BUG_ON((unsigned long) &vgetcpu != VSYSCALL_ADDR(__NR_vgetcpu));
 #ifdef CONFIG_SYSCTL
-	register_sysctl_table(kernel_root_table2);
+	register_sysctl_paths(kernel_root_path, vsyscall64_table);
 #endif
 	on_each_cpu(cpu_vsyscall_init, NULL, 1);
 	/* notifier priority > KVM */
-- 
1.7.5.134.g1c08b
