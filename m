From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 033/115] sysctl: remove .child from sunrpc/
Date: Mon,  9 May 2011 00:38:45 +0200
Message-ID: <1304894407-32201-34-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51704 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932309Ab1EHWlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:06 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/sunrpc/sysctl.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index e65dcc6..7450ab2 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -38,13 +38,17 @@ EXPORT_SYMBOL_GPL(nlm_debug);
 #ifdef RPC_DEBUG
 
 static struct ctl_table_header *sunrpc_table_header;
-static ctl_table		sunrpc_table[];
+static ctl_table sunrpc_table[];
+static const struct ctl_path sunrpc_path[] = {
+	{ .procname = "sunrpc" },
+	{ }
+};
 
 void
 rpc_register_sysctl(void)
 {
 	if (!sunrpc_table_header)
-		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+		sunrpc_table_header = register_sysctl_paths(sunrpc_path, sunrpc_table);
 }
 
 void
@@ -133,7 +137,7 @@ done:
 }
 
 
-static ctl_table debug_table[] = {
+static ctl_table sunrpc_table[] = {
 	{
 		.procname	= "rpc_debug",
 		.data		= &rpc_debug,
@@ -171,13 +175,4 @@ static ctl_table debug_table[] = {
 	{ }
 };
 
-static ctl_table sunrpc_table[] = {
-	{
-		.procname	= "sunrpc",
-		.mode		= 0555,
-		.child		= debug_table
-	},
-	{ }
-};
-
 #endif
-- 
1.7.5.134.g1c08b

