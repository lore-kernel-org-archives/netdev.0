From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 025/115] sysctl: remove .child from fs/ocfs2/nm/
Date: Mon,  9 May 2011 00:38:37 +0200
Message-ID: <1304894407-32201-26-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45747 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269Ab1EHWk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:57 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/ocfs2/stackglue.c |   36 +++++-------------------------------
 1 files changed, 5 insertions(+), 31 deletions(-)

diff --git a/fs/ocfs2/stackglue.c b/fs/ocfs2/stackglue.c
index 39abf89..3cb738a 100644
--- a/fs/ocfs2/stackglue.c
+++ b/fs/ocfs2/stackglue.c
@@ -654,36 +654,10 @@ static ctl_table ocfs2_nm_table[] = {
 	{ }
 };
 
-static ctl_table ocfs2_mod_table[] = {
-	{
-		.procname	= "nm",
-		.data		= NULL,
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= ocfs2_nm_table
-	},
-	{ }
-};
-
-static ctl_table ocfs2_kern_table[] = {
-	{
-		.procname	= "ocfs2",
-		.data		= NULL,
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= ocfs2_mod_table
-	},
-	{ }
-};
-
-static ctl_table ocfs2_root_table[] = {
-	{
-		.procname	= "fs",
-		.data		= NULL,
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= ocfs2_kern_table
-	},
+static const __initdata struct ctl_path ocfs2_nm_path[] = {
+	{ .procname = "fs" },
+	{ .procname = "ocfs2" },
+	{ .procname = "nm" },
 	{ }
 };
 
@@ -698,7 +672,7 @@ static int __init ocfs2_stack_glue_init(void)
 {
 	strcpy(cluster_stack_name, OCFS2_STACK_PLUGIN_O2CB);
 
-	ocfs2_table_header = register_sysctl_table(ocfs2_root_table);
+	ocfs2_table_header = register_sysctl_paths(ocfs2_nm_path, ocfs2_nm_table);
 	if (!ocfs2_table_header) {
 		printk(KERN_ERR
 		       "ocfs2 stack glue: unable to register sysctl\n");
-- 
1.7.5.134.g1c08b

