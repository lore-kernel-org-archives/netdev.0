From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/23] tipc: Eliminate useless memset operations in Ethernet media support
Date: Tue, 27 Dec 2011 12:39:33 -0500
Message-ID: <1325007582-31610-15-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39461 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775Ab1L0RkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:04 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of two pointless operations that zero out the array used to
record information about TIPC's Ethernet bearers. There is no need to
initialize the array on start up since it is a global variable that is
already zero'd out, and there is no need to zero it out on exit because
the array is never referenced again.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 236155c..cd0a4b8 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -371,8 +371,6 @@ int tipc_eth_media_start(void)
 	if (eth_started)
 		return -EINVAL;
 
-	memset(eth_bearers, 0, sizeof(eth_bearers));
-
 	res = tipc_register_media(&eth_media_info);
 	if (res)
 		return res;
@@ -396,6 +394,5 @@ void tipc_eth_media_stop(void)
 
 	flush_scheduled_work();
 	unregister_netdevice_notifier(&notifier);
-	memset(&eth_bearers, 0, sizeof(eth_bearers));
 	eth_started = 0;
 }
-- 
1.7.4.4
