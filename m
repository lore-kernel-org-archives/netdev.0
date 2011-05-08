From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 027/115] sysctl: remove .child from fs/xfs/
Date: Mon,  9 May 2011 00:38:39 +0200
Message-ID: <1304894407-32201-28-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51704 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab1EHWk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:59 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/xfs/linux-2.6/xfs_sysctl.c |   22 +++++-----------------
 1 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/fs/xfs/linux-2.6/xfs_sysctl.c b/fs/xfs/linux-2.6/xfs_sysctl.c
index ee2d2ad..95f803c 100644
--- a/fs/xfs/linux-2.6/xfs_sysctl.c
+++ b/fs/xfs/linux-2.6/xfs_sysctl.c
@@ -218,28 +218,16 @@ static ctl_table xfs_table[] = {
 	{}
 };
 
-static ctl_table xfs_dir_table[] = {
-	{
-		.procname	= "xfs",
-		.mode		= 0555,
-		.child		= xfs_table
-	},
-	{}
-};
-
-static ctl_table xfs_root_table[] = {
-	{
-		.procname	= "fs",
-		.mode		= 0555,
-		.child		= xfs_dir_table
-	},
-	{}
+static const __initdata struct ctl_path xfs_path[] = {
+	{ .procname = "fs" },
+	{ .procname = "xfs" },
+	{ }
 };
 
 int
 xfs_sysctl_register(void)
 {
-	xfs_table_header = register_sysctl_table(xfs_root_table);
+	xfs_table_header = register_sysctl_paths(xfs_path, xfs_table);
 	if (!xfs_table_header)
 		return -ENOMEM;
 	return 0;
-- 
1.7.5.134.g1c08b

