From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 007/115] sysctl: remove .child from abi/vsyscall32 (x86)
Date: Mon,  9 May 2011 00:38:19 +0200
Message-ID: <1304894407-32201-8-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755943Ab1EHWkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:40:37 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 arch/x86/vdso/vdso32-setup.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 468d591..e6ef3b4 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -380,7 +380,7 @@ subsys_initcall(sysenter_setup);
 /* Register vsyscall32 into the ABI table */
 #include <linux/sysctl.h>
 
-static ctl_table abi_table2[] = {
+static ctl_table abi_table[] = {
 	{
 		.procname	= "vsyscall32",
 		.data		= &sysctl_vsyscall32,
@@ -391,18 +391,14 @@ static ctl_table abi_table2[] = {
 	{}
 };
 
-static ctl_table abi_root_table2[] = {
-	{
-		.procname = "abi",
-		.mode = 0555,
-		.child = abi_table2
-	},
-	{}
+static const struct ctl_path abi_root_path[] = {
+	{ .procname = "abi" },
+	{ }
 };
 
 static __init int ia32_binfmt_init(void)
 {
-	register_sysctl_table(abi_root_table2);
+	register_sysctl_paths(abi_root_path, abi_table);
 	return 0;
 }
 __initcall(ia32_binfmt_init);
-- 
1.7.5.134.g1c08b

