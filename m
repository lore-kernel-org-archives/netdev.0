From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 021/115] sysctl: remove .child from fscache/
Date: Mon,  9 May 2011 00:38:33 +0200
Message-ID: <1304894407-32201-22-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab1EHWkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:53 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/fscache/main.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/fscache/main.c b/fs/fscache/main.c
index f9d8567..7f9c055 100644
--- a/fs/fscache/main.c
+++ b/fs/fscache/main.c
@@ -67,7 +67,7 @@ static int fscache_max_active_sysctl(struct ctl_table *table, int write,
 	return ret;
 }
 
-ctl_table fscache_sysctls[] = {
+static ctl_table fscache_table[] = {
 	{
 		.procname	= "object_max_active",
 		.data		= &fscache_object_max_active,
@@ -87,14 +87,11 @@ ctl_table fscache_sysctls[] = {
 	{}
 };
 
-ctl_table fscache_sysctls_root[] = {
-	{
-		.procname	= "fscache",
-		.mode		= 0555,
-		.child		= fscache_sysctls,
-	},
-	{}
+static const __initdata struct ctl_path fscache_path[] = {
+	{ .procname = "fscache" },
+	{ }
 };
+
 #endif
 
 /*
@@ -135,7 +132,7 @@ static int __init fscache_init(void)
 
 #ifdef CONFIG_SYSCTL
 	ret = -ENOMEM;
-	fscache_sysctl_header = register_sysctl_table(fscache_sysctls_root);
+	fscache_sysctl_header = register_sysctl_paths(fscache_path, fscache_table);
 	if (!fscache_sysctl_header)
 		goto error_sysctl;
 #endif
-- 
1.7.5.134.g1c08b

