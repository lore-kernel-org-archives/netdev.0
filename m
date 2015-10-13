From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e/i40evf: split device ids into a separate file
Date: Mon, 12 Oct 2015 22:53:11 -0700
Message-ID: <1444715598-20970-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2285 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbbJMFx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:29 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Due to desires to write userland drivers, and other requests, without
needing the rest of the include files, the device ids are pulled out
into a standalone file.

Change-ID: Ic0b047dbf9d4b0891892309c1f2079f56d9b60e8
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_devids.h   | 55 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h     | 26 +-----------
 drivers/net/ethernet/intel/i40evf/i40e_devids.h | 55 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h   | 26 +-----------
 4 files changed, 112 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_devids.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_devids.h

diff --git a/drivers/net/ethernet/intel/i40e/i40e_devids.h b/drivers/net/ethernet/intel/i40e/i40e_devids.h
new file mode 100644
index 0000000..c601ca4
--- /dev/null
+++ b/drivers/net/ethernet/intel/i40e/i40e_devids.h
@@ -0,0 +1,55 @@
+/*******************************************************************************
+ *
+ * Intel Ethernet Controller XL710 Family Linux Driver
+ * Copyright(c) 2013 - 2015 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
+
+#ifndef _I40E_DEVIDS_H_
+#define _I40E_DEVIDS_H_
+
+/* Device IDs */
+#define I40E_DEV_ID_SFP_XL710		0x1572
+#define I40E_DEV_ID_QEMU		0x1574
+#define I40E_DEV_ID_KX_A		0x157F
+#define I40E_DEV_ID_KX_B		0x1580
+#define I40E_DEV_ID_KX_C		0x1581
+#define I40E_DEV_ID_QSFP_A		0x1583
+#define I40E_DEV_ID_QSFP_B		0x1584
+#define I40E_DEV_ID_QSFP_C		0x1585
+#define I40E_DEV_ID_10G_BASE_T		0x1586
+#define I40E_DEV_ID_20G_KR2		0x1587
+#define I40E_DEV_ID_20G_KR2_A		0x1588
+#define I40E_DEV_ID_10G_BASE_T4		0x1589
+#define I40E_DEV_ID_VF			0x154C
+#define I40E_DEV_ID_VF_HV		0x1571
+#define I40E_DEV_ID_SFP_X722		0x37D0
+#define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
+#define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
+#define I40E_DEV_ID_X722_VF		0x37CD
+#define I40E_DEV_ID_X722_VF_HV		0x37D9
+
+#define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
+					 (d) == I40E_DEV_ID_QSFP_B  || \
+					 (d) == I40E_DEV_ID_QSFP_C)
+
+#endif /* _I40E_DEVIDS_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 4ec3ffa..102d0c4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -33,31 +33,7 @@
 #include "i40e_adminq.h"
 #include "i40e_hmc.h"
 #include "i40e_lan_hmc.h"
-
-/* Device IDs */
-#define I40E_DEV_ID_SFP_XL710		0x1572
-#define I40E_DEV_ID_QEMU		0x1574
-#define I40E_DEV_ID_KX_A		0x157F
-#define I40E_DEV_ID_KX_B		0x1580
-#define I40E_DEV_ID_KX_C		0x1581
-#define I40E_DEV_ID_QSFP_A		0x1583
-#define I40E_DEV_ID_QSFP_B		0x1584
-#define I40E_DEV_ID_QSFP_C		0x1585
-#define I40E_DEV_ID_10G_BASE_T		0x1586
-#define I40E_DEV_ID_20G_KR2		0x1587
-#define I40E_DEV_ID_20G_KR2_A		0x1588
-#define I40E_DEV_ID_10G_BASE_T4		0x1589
-#define I40E_DEV_ID_VF			0x154C
-#define I40E_DEV_ID_VF_HV		0x1571
-#define I40E_DEV_ID_SFP_X722		0x37D0
-#define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
-#define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
-#define I40E_DEV_ID_X722_VF		0x37CD
-#define I40E_DEV_ID_X722_VF_HV		0x37D9
-
-#define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
-					 (d) == I40E_DEV_ID_QSFP_B  || \
-					 (d) == I40E_DEV_ID_QSFP_C)
+#include "i40e_devids.h"
 
 /* I40E_MASK is a macro used on 32 bit registers */
 #define I40E_MASK(mask, shift) (mask << shift)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_devids.h b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
new file mode 100644
index 0000000..e6a39c9
--- /dev/null
+++ b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
@@ -0,0 +1,55 @@
+/*******************************************************************************
+ *
+ * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
+ * Copyright(c) 2013 - 2015 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ ******************************************************************************/
+
+#ifndef _I40E_DEVIDS_H_
+#define _I40E_DEVIDS_H_
+
+/* Device IDs */
+#define I40E_DEV_ID_SFP_XL710		0x1572
+#define I40E_DEV_ID_QEMU		0x1574
+#define I40E_DEV_ID_KX_A		0x157F
+#define I40E_DEV_ID_KX_B		0x1580
+#define I40E_DEV_ID_KX_C		0x1581
+#define I40E_DEV_ID_QSFP_A		0x1583
+#define I40E_DEV_ID_QSFP_B		0x1584
+#define I40E_DEV_ID_QSFP_C		0x1585
+#define I40E_DEV_ID_10G_BASE_T		0x1586
+#define I40E_DEV_ID_20G_KR2		0x1587
+#define I40E_DEV_ID_20G_KR2_A		0x1588
+#define I40E_DEV_ID_10G_BASE_T4		0x1589
+#define I40E_DEV_ID_VF			0x154C
+#define I40E_DEV_ID_VF_HV		0x1571
+#define I40E_DEV_ID_SFP_X722		0x37D0
+#define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
+#define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
+#define I40E_DEV_ID_X722_VF		0x37CD
+#define I40E_DEV_ID_X722_VF_HV		0x37D9
+
+#define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
+					 (d) == I40E_DEV_ID_QSFP_B  || \
+					 (d) == I40E_DEV_ID_QSFP_C)
+
+#endif /* _I40E_DEVIDS_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index b3c65dd..6dbace3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -33,31 +33,7 @@
 #include "i40e_adminq.h"
 #include "i40e_hmc.h"
 #include "i40e_lan_hmc.h"
-
-/* Device IDs */
-#define I40E_DEV_ID_SFP_XL710		0x1572
-#define I40E_DEV_ID_QEMU		0x1574
-#define I40E_DEV_ID_KX_A		0x157F
-#define I40E_DEV_ID_KX_B		0x1580
-#define I40E_DEV_ID_KX_C		0x1581
-#define I40E_DEV_ID_QSFP_A		0x1583
-#define I40E_DEV_ID_QSFP_B		0x1584
-#define I40E_DEV_ID_QSFP_C		0x1585
-#define I40E_DEV_ID_10G_BASE_T		0x1586
-#define I40E_DEV_ID_20G_KR2		0x1587
-#define I40E_DEV_ID_20G_KR2_A		0x1588
-#define I40E_DEV_ID_10G_BASE_T4		0x1589
-#define I40E_DEV_ID_VF			0x154C
-#define I40E_DEV_ID_VF_HV		0x1571
-#define I40E_DEV_ID_SFP_X722		0x37D0
-#define I40E_DEV_ID_1G_BASE_T_X722	0x37D1
-#define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
-#define I40E_DEV_ID_X722_VF		0x37CD
-#define I40E_DEV_ID_X722_VF_HV		0x37D9
-
-#define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
-					 (d) == I40E_DEV_ID_QSFP_B  || \
-					 (d) == I40E_DEV_ID_QSFP_C)
+#include "i40e_devids.h"
 
 /* I40E_MASK is a macro used on 32 bit registers */
 #define I40E_MASK(mask, shift) (mask << shift)
-- 
2.4.3
