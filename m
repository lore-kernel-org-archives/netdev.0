From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 07/10] cxgb4vf: Fail open if link_start() fails.
Date: Wed, 10 Nov 2010 18:04:09 -0800
Message-ID: <1289441052-4925-7-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3931 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932267Ab0KKCEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:22 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fail open if link_start() fails.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index b5c0bff..2d09e83 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -753,7 +753,9 @@ static int cxgb4vf_open(struct net_device *dev)
 	if (err)
 		return err;
 	set_bit(pi->port_id, &adapter->open_device_map);
-	link_start(dev);
+	err = link_start(dev);
+	if (err)
+		return err;
 	netif_tx_start_all_queues(dev);
 	return 0;
 }
-- 
1.7.0.4

