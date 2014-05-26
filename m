From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH 1/6] pch_gbe: print invalid MAC address during probe
Date: Mon, 26 May 2014 15:40:34 +0200
Message-ID: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:58893 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752555AbaEZNm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 09:42:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Krueger <daniel.krueger@systec-electronic.com>

It is also neat to show the actual offending MAC address instead of just
rejecting it

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 73e6683..42fa431 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2674,6 +2674,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 		 */
 		dev_err(&pdev->dev, "Invalid MAC address, "
 		                    "interface disabled.\n");
+		dev_err(&pdev->dev, "%pM\n", adapter->hw.mac.addr);
 	}
 	setup_timer(&adapter->watchdog_timer, pch_gbe_watchdog,
 		    (unsigned long)adapter);
-- 
1.8.5.5
