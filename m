From: sunil.kovvuri@gmail.com
Subject: [PATCH 02/21] net: thunderx: Add VNIC's PCI devid on future chips
Date: Wed, 10 Aug 2016 12:12:34 +0530
Message-ID: <1470811373-28277-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch adds PCI device IDs of VNIC on newer chips and also
registers VF driver with them. Device id remains same for all
versions of chips but subsystem device id changes.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h        | 10 +++++++++-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 14 ++++++++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 66b499b..6b0b240 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -21,7 +21,15 @@
 #define	PCI_DEVICE_ID_THUNDER_BGX		0xA026
 
 /* Subsystem device IDs */
-#define PCI_SUBSYS_DEVID_88XX_NIC_PF           0xA11E
+#define PCI_SUBSYS_DEVID_88XX_NIC_PF		0xA11E
+#define PCI_SUBSYS_DEVID_81XX_NIC_PF		0xA21E
+#define PCI_SUBSYS_DEVID_83XX_NIC_PF		0xA31E
+
+#define PCI_SUBSYS_DEVID_88XX_PASS1_NIC_VF	0xA11E
+#define PCI_SUBSYS_DEVID_88XX_NIC_VF		0xA134
+#define PCI_SUBSYS_DEVID_81XX_NIC_VF		0xA234
+#define PCI_SUBSYS_DEVID_83XX_NIC_VF		0xA334
+
 
 /* PCI BAR nos */
 #define	PCI_CFG_REG_BAR_NUM		0
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a19e73f..0c10635 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -29,10 +29,20 @@
 static const struct pci_device_id nicvf_id_table[] = {
 	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_CAVIUM,
 			 PCI_DEVICE_ID_THUNDER_NIC_VF,
-			 PCI_VENDOR_ID_CAVIUM, 0xA134) },
+			 PCI_VENDOR_ID_CAVIUM,
+			 PCI_SUBSYS_DEVID_88XX_NIC_VF) },
 	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_CAVIUM,
 			 PCI_DEVICE_ID_THUNDER_PASS1_NIC_VF,
-			 PCI_VENDOR_ID_CAVIUM, 0xA11E) },
+			 PCI_VENDOR_ID_CAVIUM,
+			 PCI_SUBSYS_DEVID_88XX_PASS1_NIC_VF) },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_CAVIUM,
+			 PCI_DEVICE_ID_THUNDER_NIC_VF,
+			 PCI_VENDOR_ID_CAVIUM,
+			 PCI_SUBSYS_DEVID_81XX_NIC_VF) },
+	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_CAVIUM,
+			 PCI_DEVICE_ID_THUNDER_NIC_VF,
+			 PCI_VENDOR_ID_CAVIUM,
+			 PCI_SUBSYS_DEVID_83XX_NIC_VF) },
 	{ 0, }  /* end of table */
 };
 
-- 
2.7.4
