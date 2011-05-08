From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 045/115] sysctl: remove .child from kernel/powersave-nap (powerpc)
Date: Mon,  9 May 2011 00:38:57 +0200
Message-ID: <1304894407-32201-46-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45747 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932415Ab1EHWlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:19 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 arch/powerpc/kernel/idle.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/kernel/idle.c b/arch/powerpc/kernel/idle.c
index 39a2baa..88d03c5 100644
--- a/arch/powerpc/kernel/idle.c
+++ b/arch/powerpc/kernel/idle.c
@@ -118,19 +118,16 @@ static ctl_table powersave_nap_ctl_table[]={
 	},
 	{}
 };
-static ctl_table powersave_nap_sysctl_root[] = {
-	{
-		.procname	= "kernel",
-		.mode		= 0555,
-		.child		= powersave_nap_ctl_table,
-	},
-	{}
+
+static const __initdata struct ctl_path powersave_nap_path[] = {
+	{ .procname = "kernel" },
+	{ }
 };
 
 static int __init
 register_powersave_nap_sysctl(void)
 {
-	register_sysctl_table(powersave_nap_sysctl_root);
+	register_sysctl_paths(powersave_nap_path, powersave_nap_ctl_table);
 
 	return 0;
 }
-- 
1.7.5.134.g1c08b

