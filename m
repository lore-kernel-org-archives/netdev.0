From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 048/115] sysctl: remove .child from sh64/unaligned_fixup/
Date: Mon,  9 May 2011 00:39:00 +0200
Message-ID: <1304894407-32201-49-git-send-email-lucian.grijincu@gmail.com>
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
 arch/sh/kernel/traps_64.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/arch/sh/kernel/traps_64.c b/arch/sh/kernel/traps_64.c
index 6713ca9..8b355b4 100644
--- a/arch/sh/kernel/traps_64.c
+++ b/arch/sh/kernel/traps_64.c
@@ -908,27 +908,16 @@ static ctl_table unaligned_table[] = {
 	{}
 };
 
-static ctl_table unaligned_root[] = {
-	{
-		.procname	= "unaligned_fixup",
-		.mode		= 0555,
-		.child		= unaligned_table
-	},
-	{}
+static const __initdata struct ctl_table unaligned_path[] = {
+	{ .procname = "sh64" },
+	{ .procname = "unaligned_fixup" },
+	{ }
 };
 
-static ctl_table sh64_root[] = {
-	{
-		.procname	= "sh64",
-		.mode		= 0555,
-		.child		= unaligned_root
-	},
-	{}
-};
 static struct ctl_table_header *sysctl_header;
 static int __init init_sysctl(void)
 {
-	sysctl_header = register_sysctl_table(sh64_root);
+	sysctl_header = register_sysctl_paths(unaligned_path, unaligned_table);
 	return 0;
 }
 
-- 
1.7.5.134.g1c08b
