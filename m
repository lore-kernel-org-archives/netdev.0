From: auke-jan.h.kok@intel.com (Auke-Jan H Kok)
Subject: [PATCH] ixgb: Don't stop queue unnecesarily
Date: Mon, 15 Jan 2007 08:40:30 -0800
Message-ID: <20070115164530.214FC4180B@ahkok-mobl.jf.intel.com>
Cc: Jonathan Lundell <jonathan.lundell@resilience.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12127 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100AbXAOQpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 11:45:31 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Cc: Auke Kok <sofar@foo-projects.org>
Cc: Jesse@ahkok-mobl.jf.intel.com,
	"Brandeburg <jesse.brandeburg"@intel.com?
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>

ixgb: Don't stop queue unnecesarily

We don't need to stop twice in ixgb_xmit_frame.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 51bd7e8..83f4d67 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1473,7 +1473,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
                      DESC_NEEDED))) {
-		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
