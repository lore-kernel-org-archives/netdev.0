From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH 3/6] IP100A Remove CONFIG_SUNDANCE_MMIO, mask of mapping
	address
Date: Thu, 17 Aug 2006 15:06:01 -0400
Message-ID: <1155841561.4532.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932112AbWHQHSh@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Remove CONFIG_SUNDANCE_MMIO, mask of mapping address

Change Logs:
    Remove CONFIG_SUNDANCE_MMIO, mask of mapping address

---

 drivers/net/sundance.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

dc932975858ae18801620d04212c516ced6920bd
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 910ea17..2bde1b3 100755
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -21,8 +21,8 @@
 */
 
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.2"
-#define DRV_RELDATE	"03-Aug-2006"
+#define DRV_VERSION	"1.01+LK1.13"
+#define DRV_RELDATE	"04-Aug-2006"
 
 
 /* The user-configurable values.
@@ -199,10 +199,6 @@ IVc. Errata
 
 */
 
-/* Work-around for Kendin chip bugs. */
-#ifndef CONFIG_SUNDANCE_MMIO
-#define USE_IO_OPS 1
-#endif
 
 static const struct pci_device_id sundance_pci_tbl[] = {
 	{ 0x1186, 0x1002, 0x1186, 0x1002, 0, 0, 0 },
@@ -491,10 +487,13 @@ #endif
 	if (pci_request_regions(pdev, DRV_NAME))
 		goto err_out_netdev;
 
-	ioaddr = pci_iomap(pdev, bar, netdev_io_size);
+	ioaddr =(void __iomem *)
+		 ((unsigned long)pci_iomap(pdev, bar, netdev_io_size) & 
+	          0xffffff80);
 	if (!ioaddr)
 		goto err_out_res;
 
+
 	for (i = 0; i < 3; i++)
 		((u16 *)dev->dev_addr)[i] =
 			le16_to_cpu(eeprom_read(ioaddr, i + EEPROM_SA_OFFSET));
-- 
1.3.GIT
