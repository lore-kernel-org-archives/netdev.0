From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 18/36] bnx2x: Calling pci_set_drvdata earlier
Date: Wed, 12 Aug 2009 21:23:28 +0300
Message-ID: <1250101408.27379.170.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbZHLSYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of error, bnx2x_init_dev calls pci_set_drvdata(pdev, NULL)

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e9e4349..9eea52d 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11884,14 +11884,14 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	bp = netdev_priv(dev);
 	bp->msglevel = debug;
 
+	pci_set_drvdata(pdev, dev);
+
 	rc = bnx2x_init_dev(pdev, dev);
 	if (rc < 0) {
 		free_netdev(dev);
 		return rc;
 	}
 
-	pci_set_drvdata(pdev, dev);
-
 	rc = bnx2x_init_bp(bp);
 	if (rc)
 		goto init_one_exit;
-- 
1.5.4.3




