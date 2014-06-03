From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/7] igb: add defaults for i210 TX/RX PBSIZE
Date: Tue,  3 Jun 2014 00:45:07 -0700
Message-ID: <1401781509-6435-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52586 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932383AbaFCHrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 03:47:36 -0400
In-Reply-To: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Set the defaults on probe for the packet buffer size registers for the
i210.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h | 3 +++
 drivers/net/ethernet/intel/igb/e1000_regs.h    | 4 ++++
 drivers/net/ethernet/intel/igb/igb_main.c      | 6 ++++++
 3 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index f85be66..11ffdba 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -329,6 +329,9 @@
 /* Timestamp in Rx buffer */
 #define E1000_RXPBS_CFG_TS_EN           0x80000000
 
+#define I210_RXPBSIZE_DEFAULT		0x000000A2 /* RXPBSIZE default */
+#define I210_TXPBSIZE_DEFAULT		0x04000014 /* TXPBSIZE default */
+
 /* SerDes Control */
 #define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 833bbb9..1cc4b1a7 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -192,6 +192,10 @@
 				    : (0x0E038 + ((_n) * 0x40)))
 #define E1000_TDWBAH(_n)  ((_n) < 4 ? (0x0383C + ((_n) * 0x100)) \
 				    : (0x0E03C + ((_n) * 0x40)))
+
+#define E1000_RXPBS	0x02404  /* Rx Packet Buffer Size - RW */
+#define E1000_TXPBS	0x03404  /* Tx Packet Buffer Size - RW */
+
 #define E1000_TDFH     0x03410  /* TX Data FIFO Head - RW */
 #define E1000_TDFT     0x03418  /* TX Data FIFO Tail - RW */
 #define E1000_TDFHS    0x03420  /* TX Data FIFO Head Saved - RW */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ea2868b..33b3a16 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2433,6 +2433,12 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* get firmware version for ethtool -i */
 	igb_set_fw_version(adapter);
 
+	/* configure RXPBSIZE and TXPBSIZE */
+	if (hw->mac.type == e1000_i210) {
+		wr32(E1000_RXPBS, I210_RXPBSIZE_DEFAULT);
+		wr32(E1000_TXPBS, I210_TXPBSIZE_DEFAULT);
+	}
+
 	setup_timer(&adapter->watchdog_timer, igb_watchdog,
 		    (unsigned long) adapter);
 	setup_timer(&adapter->phy_info_timer, igb_update_phy_info,
-- 
1.9.3
