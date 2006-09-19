From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 22/23] ixgb: convert to netdev_priv(netdev)
Date: Tue, 19 Sep 2006 10:29:23 -0700
Message-ID: <20060919172922.4605.29170.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:33037 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030347AbWISRU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:28 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


PCI error recovery code recently merged needs to use netdev_priv

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 949e5de..0ac0b75 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2230,7 +2230,7 @@ static pci_ers_result_t ixgb_io_error_de
 			             enum pci_channel_state state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	if(netif_running(netdev))
 		ixgb_down(adapter, TRUE);
@@ -2253,7 +2253,7 @@ static pci_ers_result_t ixgb_io_error_de
 static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	if(pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
@@ -2297,7 +2297,7 @@ static pci_ers_result_t ixgb_io_slot_res
 static void ixgb_io_resume (struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgb_adapter *adapter = netdev->priv;
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
 	pci_set_master(pdev);
 



---
Auke Kok <auke-jan.h.kok@intel.com>
