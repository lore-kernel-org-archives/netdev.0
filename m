From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH v2 1/2] PCI: Add Solarflare vendor ID and SFC4000 device IDs
Date: Wed, 05 Oct 2011 22:28:05 +0100
Message-ID: <1317850086.2802.35.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These will be shared between the sfc driver and a PCI quirk.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |   10 ++++++----
 drivers/net/sfc/efx.h           |    4 ----
 drivers/net/sfc/falcon.c        |    3 ++-
 drivers/net/sfc/falcon_boards.c |    3 ++-
 include/linux/pci_ids.h         |    5 +++++
 5 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b59abc7..f8b9be3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2197,13 +2197,15 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
 
 /* PCI device ID table */
 static DEFINE_PCI_DEVICE_TABLE(efx_pci_table) = {
-	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_A_P_DEVID),
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
+		    PCI_DEVICE_ID_SOLARFLARE_SFC4000A_0),
 	 .driver_data = (unsigned long) &falcon_a1_nic_type},
-	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_B_P_DEVID),
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
+		    PCI_DEVICE_ID_SOLARFLARE_SFC4000B),
 	 .driver_data = (unsigned long) &falcon_b0_nic_type},
-	{PCI_DEVICE(EFX_VENDID_SFC, BETHPAGE_A_P_DEVID),
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, BETHPAGE_A_P_DEVID),
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
-	{PCI_DEVICE(EFX_VENDID_SFC, SIENA_A_P_DEVID),
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, SIENA_A_P_DEVID),
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
 	{0}			/* end of list */
 };
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index b0d1209..c7e7523 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -15,10 +15,6 @@
 #include "filter.h"
 
 /* PCI IDs */
-#define EFX_VENDID_SFC	        0x1924
-#define FALCON_A_P_DEVID	0x0703
-#define FALCON_A_S_DEVID        0x6703
-#define FALCON_B_P_DEVID        0x0710
 #define BETHPAGE_A_P_DEVID      0x0803
 #define SIENA_A_P_DEVID         0x0813
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 94bf4aa..9334b59 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1424,7 +1424,8 @@ static int falcon_probe_nic(struct efx_nic *efx)
 		}
 
 		dev = pci_dev_get(efx->pci_dev);
-		while ((dev = pci_get_device(EFX_VENDID_SFC, FALCON_A_S_DEVID,
+		while ((dev = pci_get_device(PCI_VENDOR_ID_SOLARFLARE,
+					     PCI_DEVICE_ID_SOLARFLARE_SFC4000A_1,
 					     dev))) {
 			if (dev->bus == efx->pci_dev->bus &&
 			    dev->devfn == efx->pci_dev->devfn + 1) {
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index b9cc846..6cc16b8 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -764,7 +764,8 @@ int falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 
 	if (board->type) {
 		netif_info(efx, probe, efx->net_dev, "board is %s rev %c%d\n",
-			 (efx->pci_dev->subsystem_vendor == EFX_VENDID_SFC)
+			 (efx->pci_dev->subsystem_vendor ==
+			  PCI_VENDOR_ID_SOLARFLARE)
 			 ? board->type->ref_model : board->type->gen_type,
 			 'A' + board->major, board->minor);
 		return 0;
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index ae96bbe..1679ff6 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2302,6 +2302,11 @@
 #define PCI_DEVICE_ID_RENESAS_SH7785	0x0007
 #define PCI_DEVICE_ID_RENESAS_SH7786	0x0010
 
+#define PCI_VENDOR_ID_SOLARFLARE	0x1924
+#define PCI_DEVICE_ID_SOLARFLARE_SFC4000A_0	0x0703
+#define PCI_DEVICE_ID_SOLARFLARE_SFC4000A_1	0x6703
+#define PCI_DEVICE_ID_SOLARFLARE_SFC4000B	0x0710
+
 #define PCI_VENDOR_ID_TDI               0x192E
 #define PCI_DEVICE_ID_TDI_EHCI          0x0101
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
