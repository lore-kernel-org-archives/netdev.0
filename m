From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/7] be2net: do not use sli_family to identify skyhawk-R chip
Date: Wed, 7 Nov 2012 09:18:57 +0530
Message-ID: <9b7db7e2-6fb0-4fa6-a529-308d5f4fd6cb@CMEXHTCAS2.ad.emulex.com>
References: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25376 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499Ab2KGDqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:15 -0500
In-Reply-To: <1352260141-27725-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SKYHAWK_FAMILY will not identify all revisions of the chip.
Use device-id check (skyhawk_chip() macro) instead.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    4 ++--
 drivers/net/ethernet/emulex/benet/be_hw.h   |    5 -----
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_roce.c |    2 +-
 4 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 82f74f8..26b9b8b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -475,8 +475,8 @@ struct be_adapter {
 #define BEx_chip(adapter)	(BE3_chip(adapter) || BE2_chip(adapter))
 
 #define be_roce_supported(adapter) ((adapter->if_type == SLI_INTF_TYPE_3 || \
-				adapter->sli_family == SKYHAWK_SLI_FAMILY) && \
-				(adapter->function_mode & RDMA_ENABLED))
+				     skyhawk_chip(adapter)) && \
+				     (adapter->function_mode & RDMA_ENABLED))
 
 extern const struct ethtool_ops be_ethtool_ops;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 4ccbc36..c257207 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -105,11 +105,6 @@
 #define SLI_INTF_TYPE_2		2
 #define SLI_INTF_TYPE_3		3
 
-/* SLI family */
-#define BE_SLI_FAMILY		0x0
-#define LANCER_A0_SLI_FAMILY	0xA
-#define SKYHAWK_SLI_FAMILY      0x2
-
 /********* ISR0 Register offset **********/
 #define CEV_ISR0_OFFSET 			0xC18
 #define CEV_ISR_SIZE				4
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index e0e826a..1767bab 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3685,7 +3685,7 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 	if (addr == NULL)
 		goto pci_map_err;
 	adapter->db = addr;
-	if (adapter->sli_family == SKYHAWK_SLI_FAMILY) {
+	if (skyhawk_chip(adapter)) {
 		adapter->roce_db.size = 4096;
 		adapter->roce_db.io_addr =
 				pci_resource_start(adapter->pdev, db_reg);
diff --git a/drivers/net/ethernet/emulex/benet/be_roce.c b/drivers/net/ethernet/emulex/benet/be_roce.c
index deecc44..866900e 100644
--- a/drivers/net/ethernet/emulex/benet/be_roce.c
+++ b/drivers/net/ethernet/emulex/benet/be_roce.c
@@ -47,7 +47,7 @@ static void _be_roce_dev_add(struct be_adapter *adapter)
 		dev_info.dpp_unmapped_len = 0;
 	}
 	dev_info.pdev = adapter->pdev;
-	if (adapter->sli_family == SKYHAWK_SLI_FAMILY)
+	if (skyhawk_chip(adapter))
 		dev_info.db = adapter->db;
 	else
 		dev_info.db = adapter->roce_db.base;
-- 
1.7.1
