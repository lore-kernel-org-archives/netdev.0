From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 23/34]bnx2x: Handling probe failures
Date: Wed, 14 Jan 2009 18:43:52 +0200
Message-ID: <1231951432.11301.144.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764022AbZANQot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Failures in the probe not handled correctly - separate the flow to handle
different failures

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6ce1388..e875dd2 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10310,17 +10310,15 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		return rc;
 	}
 
-	rc = register_netdev(dev);
-	if (rc) {
-		dev_err(&pdev->dev, "Cannot register net device\n");
-		goto init_one_exit;
-	}
-
 	pci_set_drvdata(pdev, dev);
 
 	rc = bnx2x_init_bp(bp);
+	if (rc)
+		goto init_one_exit;
+
+	rc = register_netdev(dev);
 	if (rc) {
-		unregister_netdev(dev);
+		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto init_one_exit;
 	}
 
-- 
1.5.4.3




