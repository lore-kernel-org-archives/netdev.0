From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 4/7] fjes: Define hardware registers and related data
 structures
Date: Wed, 20 May 2015 08:19:43 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D862@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds registers and related data structures
definition.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |   2 +
 drivers/platform/x86/fjes/fjes_hw.h   |  31 ++++++++
 drivers/platform/x86/fjes/fjes_regs.h | 139 ++++++++++++++++++++++++++++++++++
 3 files changed, 172 insertions(+)
 create mode 100644 drivers/platform/x86/fjes/fjes_hw.h
 create mode 100644 drivers/platform/x86/fjes/fjes_regs.h

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index 5586305..efe7cc4 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -25,6 +25,8 @@
 
 #include <linux/acpi.h>
 
+#include "fjes_hw.h"
+
 #define FJES_ACPI_SYMBOL	"Extended Socket"
 
 extern char fjes_driver_name[];
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
new file mode 100644
index 0000000..c5cc4c5
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -0,0 +1,31 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
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
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#ifndef FJES_HW_H_
+#define FJES_HW_H_
+
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+
+#include "fjes_regs.h"
+
+
+#endif /* FJES_HW_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_regs.h b/drivers/platform/x86/fjes/fjes_regs.h
new file mode 100644
index 0000000..8546cb5
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_regs.h
@@ -0,0 +1,139 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
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
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#ifndef FJES_REGS_H_
+#define FJES_REGS_H_
+
+#include <linux/bitops.h>
+
+#define XSCT_DEVICE_REGISTER_SIZE 0x1000
+
+/*
+ *  register offset
+ */
+
+/* Information registers */
+#define XSCT_OWNER_EPID     0x0000  /* Owner EPID */
+#define XSCT_MAX_EP         0x0004  /* Maximum EP */
+
+/* Device Control registers */
+#define XSCT_DCTL           0x0010  /* Device Control */
+
+/* Command Control registers */
+#define XSCT_CR             0x0020  /* Command request */
+#define XSCT_CS             0x0024  /* Command status */
+#define XSCT_SHSTSAL        0x0028  /* Share status address Low */
+#define XSCT_SHSTSAH        0x002C  /* Share status address High */
+
+#define XSCT_REQBL          0x0034  /* Request Buffer length */
+#define XSCT_REQBAL         0x0038  /* Request Buffer Address Low */
+#define XSCT_REQBAH         0x003C  /* Request Buffer Address High */
+
+#define XSCT_RESPBL         0x0044  /* Response Buffer Length */
+#define XSCT_RESPBAL        0x0048  /* Response Buffer Address Low */
+#define XSCT_RESPBAH        0x004C  /* Response Buffer Address High */
+
+/* Interrupt Control registers */
+#define XSCT_IS             0x0080  /* Interrupt status */
+#define XSCT_IMS            0x0084  /* Interrupt mas set */
+#define XSCT_IMC            0x0088  /* Interrupt mask clear */
+#define XSCT_IG             0x008C  /* Interrupt generator */
+#define XSCT_ICTL           0x0090  /* Interrupt control */
+
+
+/*
+ * register structure
+ */
+
+/* Information registers */
+union REG_OWNER_EPID {
+	struct {
+		__le32 epid:16;
+		__le32:16;
+	} Bits;
+	__le32 Reg;
+};
+
+union REG_MAX_EP {
+	struct {
+		__le32 maxep:16;
+		__le32:16;
+	} Bits;
+	__le32 Reg;
+};
+
+/* Device Control registers */
+union REG_DCTL {
+	struct {
+		__le32 reset:1;
+		__le32 rsv0:15;
+		__le32 rsv1:16;
+	} Bits;
+	__le32 Reg;
+};
+
+
+/* Command Control registers */
+union REG_CR {
+	struct {
+		__le32 req_code:16;
+		__le32 err_info:14;
+		__le32 error:1;
+		__le32 req_start:1;
+	} Bits;
+	__le32 Reg;
+};
+
+union REG_CS {
+	struct {
+		__le32 req_code:16;
+		__le32 rsv0:14;
+		__le32 busy:1;
+		__le32 complete:1;
+	} Bits;
+	__le32 Reg;
+};
+
+/* Interrupt Control registers */
+union REG_ICTL {
+	struct {
+		__le32 automak:1;
+		__le32 rsv0:31;
+	} Bits;
+	__le32 Reg;
+};
+
+enum REG_ICTL_MASK {
+	REG_ICTL_MASK_INFO_UPDATE     = 1 << 20,
+	REG_ICTL_MASK_DEV_STOP_REQ    = 1 << 19,
+	REG_ICTL_MASK_TXRX_STOP_REQ   = 1 << 18,
+	REG_ICTL_MASK_TXRX_STOP_DONE  = 1 << 17,
+	REG_ICTL_MASK_RX_DATA         = 1 << 16,
+	REG_ICTL_MASK_ALL             = GENMASK(20, 16),
+};
+
+enum REG_IS_MASK {
+	REG_IS_MASK_IS_ASSERT	= 1 << 31,
+	REG_IS_MASK_EPID		= GENMASK(15, 0),
+};
+
+
+#endif /* FJES_REGS_H_ */
-- 
1.8.3.1
