From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH v2 1/6] pch_gbe: print invalid MAC address during probe
Date: Thu,  5 Jun 2014 10:53:02 +0200
Message-ID: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:42837 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751591AbaFEIys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 04:54:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Krueger <daniel.krueger@systec-electronic.com>

It is also neat to show the actual offending MAC address instead of just
rejecting it

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---

Changes in v2:
* Use just a single line

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 73e6683..cf3101c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2672,8 +2672,7 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 		 * prevent the interface from being brought up until a valid MAC
 		 * is set.
 		 */
-		dev_err(&pdev->dev, "Invalid MAC address, "
-		                    "interface disabled.\n");
+		dev_err(&pdev->dev, "Invalid MAC address %pM - interface disabled.\n", adapter->hw.mac.addr);
 	}
 	setup_timer(&adapter->watchdog_timer, pch_gbe_watchdog,
 		    (unsigned long)adapter);
-- 
1.8.5.5
