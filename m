From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 2/5] be2net: fix max VFs reported by HW
Date: Wed, 29 Aug 2012 12:07:41 +0530
Message-ID: <3d88682f-40e6-48ec-b183-e768d4340c4b@exht1.ad.emulex.com>
References: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9997 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab2H2G4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 02:56:50 -0400
In-Reply-To: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

BE3 FW allocates VF resources for upto 30 VFs per PF while a max value of 32
may be reported via PCI config space. Fix this in the driver.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d266c86..5b622993 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -110,6 +110,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define MAX_RX_POST		BE_NAPI_WEIGHT /* Frags posted at a time */
 #define RX_FRAGS_REFILL_WM	(RX_Q_LEN - MAX_RX_POST)
 
+#define MAX_VFS			30 /* Max VFs supported by BE3 FW */
 #define FW_VER_LEN		32
 
 struct be_dma_mem {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index d86d25c..def2f66 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2723,6 +2723,8 @@ static int be_get_config(struct be_adapter *adapter)
 	if (pos) {
 		pci_read_config_word(adapter->pdev, pos + PCI_SRIOV_TOTAL_VF,
 				     &dev_num_vfs);
+		if (!lancer_chip(adapter))
+			dev_num_vfs = min_t(u16, dev_num_vfs, MAX_VFS);
 		adapter->dev_num_vfs = dev_num_vfs;
 	}
 	return 0;
-- 
1.7.4
