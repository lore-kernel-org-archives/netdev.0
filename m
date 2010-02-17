From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6 4/4] be2net: implement pci shutdown handler
Date: Wed, 17 Feb 2010 17:05:37 +0530
Message-ID: <20100217113537.GA20272@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:23341 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755889Ab0BQLfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:35:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 0ce2c26..8a53efe 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2449,6 +2449,26 @@ static int be_resume(struct pci_dev *pdev)
 	return 0;
 }
 
+/*
+ * An FLR will stop BE from DMAing any data.
+ */
+static void be_shutdown(struct pci_dev *pdev)
+{
+	struct be_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev =  adapter->netdev;
+
+	netif_device_detach(netdev);
+
+	be_cmd_reset_function(adapter);
+
+	if (adapter->wol)
+		be_setup_wol(adapter, true);
+
+	pci_disable_device(pdev);
+	
+	return;
+}
+
 static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
 				pci_channel_state_t state)
 {
@@ -2544,6 +2564,7 @@ static struct pci_driver be_driver = {
 	.remove = be_remove,
 	.suspend = be_suspend,
 	.resume = be_resume,
+	.shutdown = be_shutdown,
 	.err_handler = &be_eeh_handlers
 };
 
-- 
1.6.3.3

