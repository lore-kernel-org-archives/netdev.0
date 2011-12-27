From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/23] tipc: Minor optimization to deactivation of Ethernet media suppot
Date: Tue, 27 Dec 2011 12:39:31 -0500
Message-ID: <1325007582-31610-13-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39449 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab1L0RkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:03 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Change TIPC's shutdown code to deactivate generic networking support
before terminating Ethernet media support. The deactivation of generic
networking support causes all existing bearers to be destroyed, meaning
the Ethernet media termination routine no longer has to bother marking
them as unavailable.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c      |    2 +-
 net/tipc/eth_media.c |    4 ----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index c21331d..2691cd5 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -99,8 +99,8 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 
 static void tipc_core_stop_net(void)
 {
-	tipc_eth_media_stop();
 	tipc_net_stop();
+	tipc_eth_media_stop();
 }
 
 /**
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 3b75c0d..23bf67b 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -376,10 +376,6 @@ void tipc_eth_media_stop(void)
 
 	unregister_netdevice_notifier(&notifier);
 	for (i = 0; i < MAX_ETH_BEARERS ; i++) {
-		if (eth_bearers[i].bearer) {
-			eth_bearers[i].bearer->blocked = 1;
-			eth_bearers[i].bearer = NULL;
-		}
 		if (eth_bearers[i].dev) {
 			dev_remove_pack(&eth_bearers[i].tipc_packet_type);
 			dev_put(eth_bearers[i].dev);
-- 
1.7.4.4
