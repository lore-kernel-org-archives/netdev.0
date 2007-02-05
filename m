From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/3] NetXen: Firmware crb init changes.
Date: Mon, 5 Feb 2007 07:35:26 -0800
Message-ID: <200702051535.l15FZQJn008590@dut39.unminc.com>
Cc: amitkale@netxen.com, netxenproj@linsyssoft.com, rob@netxen.com,
	sanjeev@netxen.com, wendyx@us.ibm.com
To: c@dut39.unminc.com, jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:23548 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933000AbXBEPf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:35:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: firmware crb init changes.

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---

 netxen_nic_init.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)
  
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index ec1c736..73c0c45 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -110,6 +110,7 @@ static void crb_addr_transform_setup(voi
 	crb_addr_transform(CAM);
 	crb_addr_transform(C2C1);
 	crb_addr_transform(C2C0);
+	crb_addr_transform(SMB);
 }
 
 int netxen_init_firmware(struct netxen_adapter *adapter)
@@ -543,9 +544,13 @@ int netxen_pinit_from_rom(struct netxen_
 		}
 		for (i = 0; i < n; i++) {
 
-			off =
-			    netxen_decode_crb_addr((unsigned long)buf[i].addr) +
-			    NETXEN_PCI_CRBSPACE;
+			off = netxen_decode_crb_addr((unsigned long)buf[i].addr);
+			if (off == NETXEN_ADDR_ERROR) {
+				printk(KERN_ERR"CRB init value out of range %lx\n",
+					buf[i].addr);
+				continue;
+			}
+			off += NETXEN_PCI_CRBSPACE;
 			/* skipping cold reboot MAGIC */
 			if (off == NETXEN_CAM_RAM(0x1fc))
 				continue;
@@ -662,6 +667,7 @@ void netxen_phantom_init(struct netxen_a
 	int loops = 0;
 
 	if (!pegtune_val) {
+		val = readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
 		while (val != PHAN_INITIALIZE_COMPLETE && loops < 200000) {
 			udelay(100);
 			schedule();
