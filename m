From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 039/115] sysctl: remove .child from lasat/ (mips)
Date: Mon,  9 May 2011 00:38:51 +0200
Message-ID: <1304894407-32201-40-git-send-email-lucian.grijincu@gmail.com>
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
 arch/mips/lasat/sysctl.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/arch/mips/lasat/sysctl.c b/arch/mips/lasat/sysctl.c
index d87ffd0..a6191f0 100644
--- a/arch/mips/lasat/sysctl.c
+++ b/arch/mips/lasat/sysctl.c
@@ -262,21 +262,16 @@ static ctl_table lasat_table[] = {
 	{}
 };
 
-static ctl_table lasat_root_table[] = {
-	{
-		.procname	= "lasat",
-		.mode		=  0555,
-		.child		= lasat_table
-	},
-	{}
+static const __initdata struct ctl_path lasat_path[] = {
+	{ .procname = "lasat" },
+	{ }
 };
 
 static int __init lasat_register_sysctl(void)
 {
 	struct ctl_table_header *lasat_table_header;
 
-	lasat_table_header =
-		register_sysctl_table(lasat_root_table);
+	lasat_table_header = register_sysctl_paths(lasat_path, lasat_table);
 	if (!lasat_table_header) {
 		printk(KERN_ERR "Unable to register LASAT sysctl\n");
 		return -ENOMEM;
-- 
1.7.5.134.g1c08b
