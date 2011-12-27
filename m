From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/23] tipc: Revise comment justifying release of configuration spinlock
Date: Tue, 27 Dec 2011 12:39:30 -0500
Message-ID: <1325007582-31610-12-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39434 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab1L0RkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:02 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Comment-only change to better explain why TIPC's configuration lock is
temporarily released while activating support for network interfaces,
and why the existing activation code doesn't require rework.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index b25a396..4785bf2 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -184,13 +184,12 @@ static struct sk_buff *cfg_set_own_addr(void)
 						   " (cannot change node address once assigned)");
 
 	/*
-	 * Must release all spinlocks before calling start_net() because
-	 * Linux version of TIPC calls eth_media_start() which calls
-	 * register_netdevice_notifier() which may block!
-	 *
-	 * Temporarily releasing the lock should be harmless for non-Linux TIPC,
-	 * but Linux version of eth_media_start() should really be reworked
-	 * so that it can be called with spinlocks held.
+	 * Must temporarily release configuration spinlock while switching into
+	 * networking mode as it calls tipc_eth_media_start(), which may sleep.
+	 * Releasing the lock is harmless as other locally-issued configuration
+	 * commands won't occur until this one completes, and remotely-issued
+	 * configuration commands can't be received until a local configuration
+	 * command to enable the first bearer is received and processed.
 	 */
 
 	spin_unlock_bh(&config_lock);
-- 
1.7.4.4
