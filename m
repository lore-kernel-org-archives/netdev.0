From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/14] tipc: Fix log buffer memory leak if initialization fails
Date: Tue, 17 Aug 2010 17:00:03 -0400
Message-ID: <1282078816-11844-2-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57111 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab0HQVAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:21 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anders Kaseorg <[andersk@ksplice.com]>

Moves log buffer cleanup into tipc_core_stop() so that memory allocated
for the log buffer is freed if tipc_core_start() is unsuccessful.

Signed-off-by: Anders Kaseorg <andersk@ksplice.com>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index 6964681..466b861 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -169,6 +169,7 @@ void tipc_core_stop(void)
 	tipc_nametbl_stop();
 	tipc_ref_table_stop();
 	tipc_socket_stop();
+	tipc_log_resize(0);
 }
 
 /**
@@ -203,7 +204,9 @@ static int __init tipc_init(void)
 {
 	int res;
 
-	tipc_log_resize(CONFIG_TIPC_LOG);
+	if (tipc_log_resize(CONFIG_TIPC_LOG) != 0)
+		warn("Unable to create log buffer\n");
+
 	info("Activated (version " TIPC_MOD_VER
 	     " compiled " __DATE__ " " __TIME__ ")\n");
 
@@ -230,7 +233,6 @@ static void __exit tipc_exit(void)
 	tipc_core_stop_net();
 	tipc_core_stop();
 	info("Deactivated\n");
-	tipc_log_resize(0);
 }
 
 module_init(tipc_init);
-- 
1.7.2.1

