From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 042/115] sysctl: remove .child from vm/ (s390)
Date: Mon,  9 May 2011 00:38:54 +0200
Message-ID: <1304894407-32201-43-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195Ab1EHWlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:17 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 arch/s390/mm/cmm.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/arch/s390/mm/cmm.c b/arch/s390/mm/cmm.c
index c66ffd8..0ef5bbf 100644
--- a/arch/s390/mm/cmm.c
+++ b/arch/s390/mm/cmm.c
@@ -348,13 +348,8 @@ static struct ctl_table cmm_table[] = {
 	{ }
 };
 
-static struct ctl_table cmm_dir_table[] = {
-	{
-		.procname	= "vm",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= cmm_table,
-	},
+static const __initdata struct ctl_path cmm_path[] = {
+	{ .procname = "vm" },
 	{ }
 };
 
@@ -434,7 +429,7 @@ static int __init cmm_init(void)
 {
 	int rc = -ENOMEM;
 
-	cmm_sysctl_header = register_sysctl_table(cmm_dir_table);
+	cmm_sysctl_header = register_sysctl_paths(cmm_path, cmm_table);
 	if (!cmm_sysctl_header)
 		goto out_sysctl;
 #ifdef CONFIG_CMM_IUCV
-- 
1.7.5.134.g1c08b

