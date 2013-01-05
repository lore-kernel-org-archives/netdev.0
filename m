From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH] ethtool: Add version check for et131x regs
Date: Sat,  5 Jan 2013 09:57:31 +0000
Message-ID: <1357379851-5298-1-git-send-email-mark.einon@gmail.com>
Cc: netdev@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:43973 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755501Ab3AEKTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 05:19:35 -0500
Received: by mail-wg0-f48.google.com with SMTP id dt10so8162550wgb.27
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 02:19:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added a version check for the et131x reg dump, in case the dump format
needs to be changed later.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 et131x.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/et131x.c b/et131x.c
index b36c184..8cdbec0 100644
--- a/et131x.c
+++ b/et131x.c
@@ -4,8 +4,12 @@
 
 int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
+	u8 version = (u8)(regs->version >> 24);
 	u32 *reg = (u32 *)regs->data;
 
+	if(version != 1)
+		return -1;
+
 	fprintf(stdout, "PHY Registers\n");
 	fprintf(stdout, "0x0, Basic Control Reg          = 0x%04X\n", *reg++);
 	fprintf(stdout, "0x1, Basic Status Reg           = 0x%04X\n", *reg++);
-- 
1.7.9.5
