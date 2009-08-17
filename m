From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 3/3] be2net: destroy mcc queue before tx queues
Date: Mon, 17 Aug 2009 16:28:41 +0530
Message-ID: <20090817105841.GA10251@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:41215 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757664AbZHQK6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 06:58:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mcc queue uses the tx event queue.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 010175f..7b9efee 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1655,12 +1655,12 @@ do_none:
 
 static int be_clear(struct be_adapter *adapter)
 {
+	be_mcc_queues_destroy(adapter);
 	be_rx_queues_destroy(adapter);
 	be_tx_queues_destroy(adapter);
 
 	be_cmd_if_destroy(adapter, adapter->if_handle);
 
-	be_mcc_queues_destroy(adapter);
 	return 0;
 }
 
-- 
1.6.0.4

