From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v4 02/13] net: ethernet: aquantia: Common functions and definitions
Date: Wed, 11 Jan 2017 19:53:06 -0800
Message-ID: <20a9e54c90f44662be120d9c863a89f1ffe340e5.1484192452.git.vomlehn@texas.net>
References: <cover.1484192452.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:43692 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752167AbdALDyB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 22:54:01 -0500
In-Reply-To: <cover.1484192452.git.vomlehn@texas.net>
In-Reply-To: <c1ad2600fae843ad7f21a7eb41a096aa3cdf239b.1484192452.git.vomlehn@texas.net>
References: <cover.1484192452.git.vomlehn@texas.net> <c1ad2600fae843ad7f21a7eb41a096aa3cdf239b.1484192452.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add files containing the functions and definitions used in common in
different functional areas.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/aq_cfg.h    | 78 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/aquantia/aq_common.h | 24 ++++++++++
 drivers/net/ethernet/aquantia/aq_utils.h  | 54 +++++++++++++++++++++
 3 files changed, 156 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/aq_cfg.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_common.h
 create mode 100644 drivers/net/ethernet/aquantia/aq_utils.h

diff --git a/drivers/net/ethernet/aquantia/aq_cfg.h b/drivers/net/ethernet/aquantia/aq_cfg.h
new file mode 100644
index 0000000..63f01b8
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_cfg.h
@@ -0,0 +1,78 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_cfg.h: Definition of configuration parameters and constants. */
+
+#ifndef AQ_CFG_H
+#define AQ_CFG_H
+
+#define AQ_CFG_VECS_DEF   4U
+#define AQ_CFG_TCS_DEF    1U
+
+#define AQ_CFG_TXDS_DEF    4096U
+#define AQ_CFG_RXDS_DEF    1024U
+
+#define AQ_CFG_IS_POLLING_DEF 0U
+
+#define AQ_CFG_FORCE_LEGACY_INT 0U
+
+#define AQ_CFG_IS_INTERRUPT_MODERATION_DEF   1U
+#define AQ_CFG_INTERRUPT_MODERATION_RATE_DEF 0xFFFFU
+#define AQ_CFG_IRQ_MASK                      0x1FFU
+
+#define AQ_CFG_VECS_MAX   8U
+#define AQ_CFG_TCS_MAX    8U
+
+#define AQ_CFG_TX_FRAME_MAX  (16U * 1024U)
+#define AQ_CFG_RX_FRAME_MAX  (4U * 1024U)
+
+/* LRO */
+#define AQ_CFG_IS_LRO_DEF           1U
+
+/* RSS */
+#define AQ_CFG_RSS_INDIRECTION_TABLE_MAX  128U
+#define AQ_CFG_RSS_HASHKEY_SIZE           320U
+
+#define AQ_CFG_IS_RSS_DEF           1U
+#define AQ_CFG_NUM_RSS_QUEUES_DEF   AQ_CFG_VECS_DEF
+#define AQ_CFG_RSS_BASE_CPU_NUM_DEF 0U
+
+#define AQ_CFG_PCI_FUNC_MSIX_IRQS   9U
+#define AQ_CFG_PCI_FUNC_PORTS       2U
+
+#define AQ_CFG_SERVICE_TIMER_INTERVAL    (2 * HZ)
+#define AQ_CFG_POLLING_TIMER_INTERVAL   ((unsigned int)(2 * HZ))
+
+#define AQ_CFG_SKB_FRAGS_MAX   32U
+
+#define AQ_CFG_NAPI_WEIGHT     64U
+
+#define AQ_CFG_MULTICAST_ADDRESS_MAX     32U
+
+/*#define AQ_CFG_MAC_ADDR_PERMANENT {0x30, 0x0E, 0xE3, 0x12, 0x34, 0x56}*/
+
+#define AQ_CFG_FC_MODE 3U
+
+#define AQ_CFG_SPEED_MSK  0xFFFFU	/* 0xFFFFU==auto_neg */
+
+#define AQ_CFG_IS_AUTONEG_DEF       1U
+#define AQ_CFG_MTU_DEF              1514U
+
+#define AQ_CFG_LOCK_TRYS   100U
+
+#define AQ_CFG_DRV_AUTHOR      "aQuantia"
+#define AQ_CFG_DRV_DESC        "aQuantia Corporation(R) Network Driver"
+#define AQ_CFG_DRV_NAME        "aquantia"
+#define AQ_CFG_DRV_VERSION	__stringify(NIC_MAJOR_DRIVER_VERSION)"."\
+				__stringify(NIC_MINOR_DRIVER_VERSION)"."\
+				__stringify(NIC_BUILD_DRIVER_VERSION)"."\
+				__stringify(NIC_REVISION_DRIVER_VERSION)
+
+#endif /* AQ_CFG_H */
+
diff --git a/drivers/net/ethernet/aquantia/aq_common.h b/drivers/net/ethernet/aquantia/aq_common.h
new file mode 100644
index 0000000..af00d48
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_common.h
@@ -0,0 +1,24 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_common.h: Basic includes for all files in project. */
+
+#ifndef AQ_COMMON_H
+#define AQ_COMMON_H
+
+#include <linux/etherdevice.h>
+#include <linux/pci.h>
+
+#include "ver.h"
+#include "aq_nic.h"
+#include "aq_cfg.h"
+#include "aq_utils.h"
+
+#endif /* AQ_COMMON_H */
+
diff --git a/drivers/net/ethernet/aquantia/aq_utils.h b/drivers/net/ethernet/aquantia/aq_utils.h
new file mode 100644
index 0000000..e8b4167
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/aq_utils.h
@@ -0,0 +1,54 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_utils.h: Useful macro and structures used in all layers of driver. */
+
+#ifndef AQ_UTILS_H
+#define AQ_UTILS_H
+
+#include "aq_common.h"
+
+#ifndef MBIT
+#define MBIT ((u64)1000000U)
+#define GBIT ((u64)1000000000U)
+#endif
+
+#define AQ_IRQ_INVALID 0U
+#define AQ_IRQ_LEGACY  1U
+#define AQ_IRQ_MSI     2U
+#define AQ_IRQ_MSIX    3U
+
+#define AQ_DIMOF(_ARY_)  ARRAY_SIZE(_ARY_)
+
+#define AQ_OBJ_HEADER spinlock_t lock; atomic_t flags; atomic_t busy_count
+
+struct aq_obj_s {
+	AQ_OBJ_HEADER;
+};
+
+#define AQ_OBJ_TST(_OBJ_, _FLAG_)  ((_FLAG_) & atomic_read(&(_OBJ_)->flags))
+
+#define AQ_OBJ_SET(_OBJ_, _F_) \
+{ unsigned long flags_old, flags_new; atomic_t *flags = &(_OBJ_)->flags; \
+do { \
+	flags_old = atomic_read(flags); \
+	flags_new = flags_old | (_F_); \
+} while (atomic_cmpxchg(flags, \
+	flags_old, flags_new) != flags_old); }
+
+#define AQ_OBJ_CLR(_OBJ_, _F_) \
+{ unsigned long flags_old, flags_new; atomic_t *flags = &(_OBJ_)->flags; \
+do { \
+	flags_old = atomic_read(flags); \
+	flags_new = flags_old & ~(_F_); \
+} while (atomic_cmpxchg(flags, \
+	flags_old, flags_new) != flags_old); }
+
+#endif /* AQ_UTILS_H */
+
-- 
2.7.4
