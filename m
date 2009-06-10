From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 1/5] be2net: Use cancel_delayed_work_sync instead
	of cancel_delayed_work()
Date: Wed, 10 Jun 2009 17:48:35 +0530
Message-ID: <20090610121835.GA16411@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52376 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755373AbZFJMS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:18:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use cancel_delayed_work_sycn instead of cancel_delayed_work() to reliably kill be_worker() as it rearms itself.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 347d002..69046a1 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1533,7 +1533,7 @@ static int be_close(struct net_device *netdev)
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	int vec;
 
-	cancel_delayed_work(&adapter->work);
+	cancel_delayed_work_sync(&adapter->work);
 
 	netif_stop_queue(netdev);
 	netif_carrier_off(netdev);
-- 
1.6.0.4

