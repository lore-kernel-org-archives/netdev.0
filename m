From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/10] tipc: Optimize termination of configuration service
Date: Mon, 30 Apr 2012 18:37:01 -0400
Message-ID: <1335825428-16053-4-git-send-email-paul.gortmaker@windriver.com>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35018 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756767Ab2D3WhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:16 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Termination no longer tests to see if the configuration service
port was successfully created or not. In the unlikely event that the
port was not created, attempting to delete the non-existent port is
detected gracefully and causes no harm.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index a4988cd..843d7ae 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -506,8 +506,6 @@ void tipc_cfg_reinit(void)
 
 void tipc_cfg_stop(void)
 {
-	if (config_port_ref) {
-		tipc_deleteport(config_port_ref);
-		config_port_ref = 0;
-	}
+	tipc_deleteport(config_port_ref);
+	config_port_ref = 0;
 }
-- 
1.7.9.6
