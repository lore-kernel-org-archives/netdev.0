From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 015/115] sysctl: remove .child from xpc/
Date: Mon,  9 May 2011 00:38:27 +0200
Message-ID: <1304894407-32201-16-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/misc/sgi-xp/xpc_main.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/misc/sgi-xp/xpc_main.c b/drivers/misc/sgi-xp/xpc_main.c
index 8d082b4..642efb1 100644
--- a/drivers/misc/sgi-xp/xpc_main.c
+++ b/drivers/misc/sgi-xp/xpc_main.c
@@ -122,13 +122,11 @@ static ctl_table xpc_sys_xpc_dir[] = {
 	 .extra2 = &xpc_disengage_max_timelimit},
 	{}
 };
-static ctl_table xpc_sys_dir[] = {
-	{
-	 .procname = "xpc",
-	 .mode = 0555,
-	 .child = xpc_sys_xpc_dir},
-	{}
+static const __initdata struct ctl_path xpc_path[] = {
+	{ .procname = "xpc" },
+	{ }
 };
+
 static struct ctl_table_header *xpc_sysctl;
 
 /* non-zero if any remote partition disengage was timed out */
@@ -1236,7 +1234,7 @@ xpc_init(void)
 		goto out_1;
 	}
 
-	xpc_sysctl = register_sysctl_table(xpc_sys_dir);
+	xpc_sysctl = register_sysctl_paths(xpc_path, xpc_sys_xpc_dir);
 
 	/*
 	 * Fill the partition reserved page with the information needed by
-- 
1.7.5.134.g1c08b
