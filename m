From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 6/9] cxgb4: propagate link initialization errors to .ndo_open's callers
Date: Fri, 18 Jun 2010 13:05:32 -0700
Message-ID: <1276891535-13967-7-git-send-email-dm@chelsio.com>
References: <1276891535-13967-1-git-send-email-dm@chelsio.com>
 <1276891535-13967-2-git-send-email-dm@chelsio.com>
 <1276891535-13967-3-git-send-email-dm@chelsio.com>
 <1276891535-13967-4-git-send-email-dm@chelsio.com>
 <1276891535-13967-5-git-send-email-dm@chelsio.com>
 <1276891535-13967-6-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14796 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933374Ab0FRUMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 16:12:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5IKCJQO018644
	for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 13:12:21 -0700
In-Reply-To: <1276891535-13967-6-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 6bfe7d6..eb1492f 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2512,9 +2512,10 @@ static int cxgb_open(struct net_device *dev)
 	}
 
 	dev->real_num_tx_queues = pi->nqsets;
-	link_start(dev);
-	netif_tx_start_all_queues(dev);
-	return 0;
+	err = link_start(dev);
+	if (!err)
+		netif_tx_start_all_queues(dev);
+	return err;
 }
 
 static int cxgb_close(struct net_device *dev)
-- 
1.5.4

