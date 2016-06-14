From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v3 1/7] vmxnet3: prepare for version 3 changes
Date: Mon, 13 Jun 2016 18:50:01 -0700
Message-ID: <1465869007-10822-2-git-send-email-skhare@vmware.com>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/Makefile          |  4 ++--
 drivers/net/vmxnet3/upt1_defs.h       |  4 ++--
 drivers/net/vmxnet3/vmxnet3_defs.h    |  9 ++++++---
 drivers/net/vmxnet3/vmxnet3_drv.c     | 22 +++++++++++++---------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |  4 ++--
 drivers/net/vmxnet3/vmxnet3_int.h     | 13 +++++++++++--
 6 files changed, 36 insertions(+), 20 deletions(-)

diff --git a/drivers/net/vmxnet3/Makefile b/drivers/net/vmxnet3/Makefile
index 880f509..8cdbb63 100644
--- a/drivers/net/vmxnet3/Makefile
+++ b/drivers/net/vmxnet3/Makefile
@@ -2,7 +2,7 @@
 #
 # Linux driver for VMware's vmxnet3 ethernet NIC.
 #
-# Copyright (C) 2007-2009, VMware, Inc. All Rights Reserved.
+# Copyright (C) 2007-2016, VMware, Inc. All Rights Reserved.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms of the GNU General Public License as published by the
@@ -21,7 +21,7 @@
 # The full GNU General Public License is included in this distribution in
 # the file called "COPYING".
 #
-# Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+# Maintained by: pv-drivers@vmware.com
 #
 #
 ################################################################################
diff --git a/drivers/net/vmxnet3/upt1_defs.h b/drivers/net/vmxnet3/upt1_defs.h
index 969c751..db9f1fd 100644
--- a/drivers/net/vmxnet3/upt1_defs.h
+++ b/drivers/net/vmxnet3/upt1_defs.h
@@ -1,7 +1,7 @@
 /*
  * Linux driver for VMware's vmxnet3 ethernet NIC.
  *
- * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
+ * Copyright (C) 2008-2016, VMware, Inc. All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -20,7 +20,7 @@
  * The full GNU General Public License is included in this distribution in
  * the file called "COPYING".
  *
- * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ * Maintained by: pv-drivers@vmware.com
  *
  */
 
diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 72ba8ae..8345e0c 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -1,7 +1,7 @@
 /*
  * Linux driver for VMware's vmxnet3 ethernet NIC.
  *
- * Copyright (C) 2008-2015, VMware, Inc. All Rights Reserved.
+ * Copyright (C) 2008-2016, VMware, Inc. All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -20,7 +20,7 @@
  * The full GNU General Public License is included in this distribution in
  * the file called "COPYING".
  *
- * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ * Maintained by: pv-drivers@vmware.com
  *
  */
 
@@ -76,7 +76,9 @@ enum {
 	VMXNET3_CMD_UPDATE_IML,
 	VMXNET3_CMD_UPDATE_PMCFG,
 	VMXNET3_CMD_UPDATE_FEATURE,
+	VMXNET3_CMD_RESERVED1,
 	VMXNET3_CMD_LOAD_PLUGIN,
+	VMXNET3_CMD_RESERVED2,
 
 	VMXNET3_CMD_FIRST_GET = 0xF00D0000,
 	VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
@@ -87,7 +89,8 @@ enum {
 	VMXNET3_CMD_GET_DID_LO,
 	VMXNET3_CMD_GET_DID_HI,
 	VMXNET3_CMD_GET_DEV_EXTRA_INFO,
-	VMXNET3_CMD_GET_CONF_INTR
+	VMXNET3_CMD_GET_CONF_INTR,
+	VMXNET3_CMD_GET_RESERVED1,
 };
 
 /*
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 08885bc..507c53d 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1,7 +1,7 @@
 /*
  * Linux driver for VMware's vmxnet3 ethernet NIC.
  *
- * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
+ * Copyright (C) 2008-2016, VMware, Inc. All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -20,7 +20,7 @@
  * The full GNU General Public License is included in this distribution in
  * the file called "COPYING".
  *
- * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ * Maintained by: pv-drivers@vmware.com
  *
  */
 
@@ -1363,7 +1363,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			rbi->dma_addr = new_dma_addr;
 			rxd->addr = cpu_to_le64(rbi->dma_addr);
 			rxd->len = rbi->len;
-			if (adapter->version == 2 &&
+			if (VMXNET3_VERSION_GE_2(adapter) &&
 			    rcd->type == VMXNET3_CDTYPE_RXCOMP_LRO) {
 				struct Vmxnet3_RxCompDescExt *rcdlro;
 				rcdlro = (struct Vmxnet3_RxCompDescExt *)rcd;
@@ -3200,12 +3200,16 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_pci;
 
 	ver = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_VRRS);
-	if (ver & 2) {
-		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_VRRS, 2);
-		adapter->version = 2;
-	} else if (ver & 1) {
-		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_VRRS, 1);
-		adapter->version = 1;
+	if (ver & (1 << VMXNET3_REV_2)) {
+		VMXNET3_WRITE_BAR1_REG(adapter,
+				       VMXNET3_REG_VRRS,
+				       1 << VMXNET3_REV_2);
+		adapter->version = VMXNET3_REV_2 + 1;
+	} else if (ver & (1 << VMXNET3_REV_1)) {
+		VMXNET3_WRITE_BAR1_REG(adapter,
+				       VMXNET3_REG_VRRS,
+				       1 << VMXNET3_REV_1);
+		adapter->version = VMXNET3_REV_1 + 1;
 	} else {
 		dev_err(&pdev->dev,
 			"Incompatible h/w version (0x%x) for adapter\n", ver);
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 9ba11d7..163e99c 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -1,7 +1,7 @@
 /*
  * Linux driver for VMware's vmxnet3 ethernet NIC.
  *
- * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
+ * Copyright (C) 2008-2016, VMware, Inc. All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -20,7 +20,7 @@
  * The full GNU General Public License is included in this distribution in
  * the file called "COPYING".
  *
- * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ * Maintained by: pv-drivers@vmware.com
  *
  */
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 3d2b64e..de068e9 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -1,7 +1,7 @@
 /*
  * Linux driver for VMware's vmxnet3 ethernet NIC.
  *
- * Copyright (C) 2008-2009, VMware, Inc. All Rights Reserved.
+ * Copyright (C) 2008-2016, VMware, Inc. All Rights Reserved.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the
@@ -20,7 +20,7 @@
  * The full GNU General Public License is included in this distribution in
  * the file called "COPYING".
  *
- * Maintained by: Shreyas Bhatewara <pv-drivers@vmware.com>
+ * Maintained by: pv-drivers@vmware.com
  *
  */
 
@@ -79,6 +79,10 @@
 	#define VMXNET3_RSS
 #endif
 
+#define VMXNET3_REV_3		2	/* Vmxnet3 Rev. 3 */
+#define VMXNET3_REV_2		1	/* Vmxnet3 Rev. 2 */
+#define VMXNET3_REV_1		0	/* Vmxnet3 Rev. 1 */
+
 /*
  * Capabilities
  */
@@ -387,6 +391,11 @@ struct vmxnet3_adapter {
 #define VMXNET3_GET_ADDR_LO(dma)   ((u32)(dma))
 #define VMXNET3_GET_ADDR_HI(dma)   ((u32)(((u64)(dma)) >> 32))
 
+#define VMXNET3_VERSION_GE_2(adapter) \
+	(adapter->version >= VMXNET3_REV_2 + 1)
+#define VMXNET3_VERSION_GE_3(adapter) \
+	(adapter->version >= VMXNET3_REV_3 + 1)
+
 /* must be a multiple of VMXNET3_RING_SIZE_ALIGN */
 #define VMXNET3_DEF_TX_RING_SIZE    512
 #define VMXNET3_DEF_RX_RING_SIZE    256
-- 
2.8.2
