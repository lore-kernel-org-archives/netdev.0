From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 6/9] cxgb4: propagate link initialization errors to .ndo_open's callers
Date: Wed, 16 Jun 2010 15:01:13 -0700
Message-ID: <1276725676-31514-7-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
 <1276725676-31514-2-git-send-email-dm@chelsio.com>
 <1276725676-31514-3-git-send-email-dm@chelsio.com>
 <1276725676-31514-4-git-send-email-dm@chelsio.com>
 <1276725676-31514-5-git-send-email-dm@chelsio.com>
 <1276725676-31514-6-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14386 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759356Ab0FPWBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:18 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1IgK032130
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:18 -0700
In-Reply-To: <1276725676-31514-6-git-send-email-dm@chelsio.com>
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

