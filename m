From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 032/115] sysctl: remove .child from kernel/ (utsname)
Date: Mon,  9 May 2011 00:38:44 +0200
Message-ID: <1304894407-32201-33-git-send-email-lucian.grijincu@gmail.com>
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
 kernel/utsname_sysctl.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/kernel/utsname_sysctl.c b/kernel/utsname_sysctl.c
index a2cd77e..7606026 100644
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -57,7 +57,7 @@ static int proc_do_uts_string(ctl_table *table, int write,
 #define proc_do_uts_string NULL
 #endif
 
-static struct ctl_table uts_kern_table[] = {
+static struct ctl_table uts_table[] = {
 	{
 		.procname	= "ostype",
 		.data		= init_uts_ns.name.sysname,
@@ -96,18 +96,14 @@ static struct ctl_table uts_kern_table[] = {
 	{}
 };
 
-static struct ctl_table uts_root_table[] = {
-	{
-		.procname	= "kernel",
-		.mode		= 0555,
-		.child		= uts_kern_table,
-	},
-	{}
+static const __initdata struct ctl_path uts_path[] = {
+	{ .procname = "kernel" },
+	{ },
 };
 
 static int __init utsname_sysctl_init(void)
 {
-	register_sysctl_table(uts_root_table);
+	register_sysctl_paths(uts_path, uts_table);
 	return 0;
 }
 
-- 
1.7.5.134.g1c08b
