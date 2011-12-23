From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] ixgbevf: Fix register defines to correctly handle complex expressions
Date: Fri, 23 Dec 2011 01:09:09 -0800
Message-ID: <1324631357-31789-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9686 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753775Ab1LWJJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:20 -0500
In-Reply-To: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to address possible issues with the IXGBEVF register
defines generating incorrect values when given a complex expression for the
register offset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/mbx.h  |    4 +-
 drivers/net/ethernet/intel/ixgbevf/regs.h |   42 ++++++++++++++--------------
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index ea393eb..9d38a94 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -47,8 +47,8 @@
 #define IXGBE_VFMAILBOX_RSTD     0x00000080 /* PF has indicated reset done */
 #define IXGBE_VFMAILBOX_R2C_BITS 0x000000B0 /* All read to clear bits */
 
-#define IXGBE_PFMAILBOX(x)          (0x04B00 + (4 * x))
-#define IXGBE_PFMBMEM(vfn)          (0x13000 + (64 * vfn))
+#define IXGBE_PFMAILBOX(x)          (0x04B00 + (4 * (x)))
+#define IXGBE_PFMBMEM(vfn)          (0x13000 + (64 * (vfn)))
 
 #define IXGBE_PFMAILBOX_STS   0x00000001 /* Initiate message send to VF */
 #define IXGBE_PFMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
diff --git a/drivers/net/ethernet/intel/ixgbevf/regs.h b/drivers/net/ethernet/intel/ixgbevf/regs.h
index 189200e..5e4d5e5 100644
--- a/drivers/net/ethernet/intel/ixgbevf/regs.h
+++ b/drivers/net/ethernet/intel/ixgbevf/regs.h
@@ -39,29 +39,29 @@
 #define IXGBE_VTEIMC           0x0010C
 #define IXGBE_VTEIAC           0x00110
 #define IXGBE_VTEIAM           0x00114
-#define IXGBE_VTEITR(x)        (0x00820 + (4 * x))
-#define IXGBE_VTIVAR(x)        (0x00120 + (4 * x))
+#define IXGBE_VTEITR(x)        (0x00820 + (4 * (x)))
+#define IXGBE_VTIVAR(x)        (0x00120 + (4 * (x)))
 #define IXGBE_VTIVAR_MISC      0x00140
-#define IXGBE_VTRSCINT(x)      (0x00180 + (4 * x))
-#define IXGBE_VFRDBAL(x)       (0x01000 + (0x40 * x))
-#define IXGBE_VFRDBAH(x)       (0x01004 + (0x40 * x))
-#define IXGBE_VFRDLEN(x)       (0x01008 + (0x40 * x))
-#define IXGBE_VFRDH(x)         (0x01010 + (0x40 * x))
-#define IXGBE_VFRDT(x)         (0x01018 + (0x40 * x))
-#define IXGBE_VFRXDCTL(x)      (0x01028 + (0x40 * x))
-#define IXGBE_VFSRRCTL(x)      (0x01014 + (0x40 * x))
-#define IXGBE_VFRSCCTL(x)      (0x0102C + (0x40 * x))
+#define IXGBE_VTRSCINT(x)      (0x00180 + (4 * (x)))
+#define IXGBE_VFRDBAL(x)       (0x01000 + (0x40 * (x)))
+#define IXGBE_VFRDBAH(x)       (0x01004 + (0x40 * (x)))
+#define IXGBE_VFRDLEN(x)       (0x01008 + (0x40 * (x)))
+#define IXGBE_VFRDH(x)         (0x01010 + (0x40 * (x)))
+#define IXGBE_VFRDT(x)         (0x01018 + (0x40 * (x)))
+#define IXGBE_VFRXDCTL(x)      (0x01028 + (0x40 * (x)))
+#define IXGBE_VFSRRCTL(x)      (0x01014 + (0x40 * (x)))
+#define IXGBE_VFRSCCTL(x)      (0x0102C + (0x40 * (x)))
 #define IXGBE_VFPSRTYPE        0x00300
-#define IXGBE_VFTDBAL(x)       (0x02000 + (0x40 * x))
-#define IXGBE_VFTDBAH(x)       (0x02004 + (0x40 * x))
-#define IXGBE_VFTDLEN(x)       (0x02008 + (0x40 * x))
-#define IXGBE_VFTDH(x)         (0x02010 + (0x40 * x))
-#define IXGBE_VFTDT(x)         (0x02018 + (0x40 * x))
-#define IXGBE_VFTXDCTL(x)      (0x02028 + (0x40 * x))
-#define IXGBE_VFTDWBAL(x)      (0x02038 + (0x40 * x))
-#define IXGBE_VFTDWBAH(x)      (0x0203C + (0x40 * x))
-#define IXGBE_VFDCA_RXCTRL(x)  (0x0100C + (0x40 * x))
-#define IXGBE_VFDCA_TXCTRL(x)  (0x0200c + (0x40 * x))
+#define IXGBE_VFTDBAL(x)       (0x02000 + (0x40 * (x)))
+#define IXGBE_VFTDBAH(x)       (0x02004 + (0x40 * (x)))
+#define IXGBE_VFTDLEN(x)       (0x02008 + (0x40 * (x)))
+#define IXGBE_VFTDH(x)         (0x02010 + (0x40 * (x)))
+#define IXGBE_VFTDT(x)         (0x02018 + (0x40 * (x)))
+#define IXGBE_VFTXDCTL(x)      (0x02028 + (0x40 * (x)))
+#define IXGBE_VFTDWBAL(x)      (0x02038 + (0x40 * (x)))
+#define IXGBE_VFTDWBAH(x)      (0x0203C + (0x40 * (x)))
+#define IXGBE_VFDCA_RXCTRL(x)  (0x0100C + (0x40 * (x)))
+#define IXGBE_VFDCA_TXCTRL(x)  (0x0200c + (0x40 * (x)))
 #define IXGBE_VFGPRC           0x0101C
 #define IXGBE_VFGPTC           0x0201C
 #define IXGBE_VFGORC_LSB       0x01020
-- 
1.7.7.4
