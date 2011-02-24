From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/17] tipc: Eliminate unnecessary locking when starting topology service
Date: Wed, 23 Feb 2011 20:26:37 -0500
Message-ID: <1298510805-20630-10-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34511 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab1BXB1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:11 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Modifies the initialization code for TIPC's topology service to
avoid taking the spinlock protecting the subscriber list, since
there is no need to do this.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/subscr.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 98ee50b..1387372 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -542,7 +542,6 @@ int tipc_subscr_start(void)
 	spin_lock_init(&topsrv.lock);
 	INIT_LIST_HEAD(&topsrv.subscriber_list);
 
-	spin_lock_bh(&topsrv.lock);
 	res = tipc_createport(NULL,
 			      TIPC_CRITICAL_IMPORTANCE,
 			      NULL,
@@ -563,12 +562,10 @@ int tipc_subscr_start(void)
 		goto failed;
 	}
 
-	spin_unlock_bh(&topsrv.lock);
 	return 0;
 
 failed:
 	err("Failed to create subscription service\n");
-	spin_unlock_bh(&topsrv.lock);
 	return res;
 }
 
-- 
1.7.3.3

