From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 022/115] sysctl: remove .child from fs/nfs/ nlm_table table
Date: Mon,  9 May 2011 00:38:34 +0200
Message-ID: <1304894407-32201-23-git-send-email-lucian.grijincu@gmail.com>
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
 fs/lockd/svc.c |   22 +++++-----------------
 1 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abfff9d..6ab5932 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -355,7 +355,7 @@ EXPORT_SYMBOL_GPL(lockd_down);
  * Sysctl parameters (same as module parameters, different interface).
  */
 
-static ctl_table nlm_sysctls[] = {
+static ctl_table nlm_table[] = {
 	{
 		.procname	= "nlm_grace_period",
 		.data		= &nlm_grace_period,
@@ -409,21 +409,9 @@ static ctl_table nlm_sysctls[] = {
 	{ }
 };
 
-static ctl_table nlm_sysctl_dir[] = {
-	{
-		.procname	= "nfs",
-		.mode		= 0555,
-		.child		= nlm_sysctls,
-	},
-	{ }
-};
-
-static ctl_table nlm_sysctl_root[] = {
-	{
-		.procname	= "fs",
-		.mode		= 0555,
-		.child		= nlm_sysctl_dir,
-	},
+static const __initdata struct ctl_path nlm_path[] = {
+	{ .procname = "fs" },
+	{ .procname = "nfs" },
 	{ }
 };
 
@@ -504,7 +492,7 @@ module_param(nlm_max_connections, uint, 0644);
 static int __init init_nlm(void)
 {
 #ifdef CONFIG_SYSCTL
-	nlm_sysctl_table = register_sysctl_table(nlm_sysctl_root);
+	nlm_sysctl_table = register_sysctl_paths(nlm_path, nlm_table);
 	return nlm_sysctl_table ? 0 : -ENOMEM;
 #else
 	return 0;
-- 
1.7.5.134.g1c08b
