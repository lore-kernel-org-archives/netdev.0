From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] e1000e: fix sparse warnings with -D__CHECK_ENDIAN__
Date: Tue,  7 Feb 2012 04:33:57 -0800
Message-ID: <1328618038-5008-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30741 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756167Ab2BGMeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:15 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  |   15 ++++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index fd2ba38..f4dc0fa 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -553,7 +553,7 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	memcpy(ptr, bytes, eeprom->len);
 
 	for (i = 0; i < last_word - first_word + 1; i++)
-		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
+		cpu_to_le16s(&eeprom_buff[i]);
 
 	ret_val = e1000_write_nvm(hw, first_word,
 				  last_word - first_word + 1, eeprom_buff);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a9f25fc..2ac1164 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -183,18 +183,18 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	struct e1000_tx_desc *tx_desc;
 	struct my_u0 {
-		u64 a;
-		u64 b;
+		__le64 a;
+		__le64 b;
 	} *u0;
 	struct e1000_buffer *buffer_info;
 	struct e1000_ring *rx_ring = adapter->rx_ring;
 	union e1000_rx_desc_packet_split *rx_desc_ps;
 	union e1000_rx_desc_extended *rx_desc;
 	struct my_u1 {
-		u64 a;
-		u64 b;
-		u64 c;
-		u64 d;
+		__le64 a;
+		__le64 b;
+		__le64 c;
+		__le64 d;
 	} *u1;
 	u32 staterr;
 	int i = 0;
@@ -5963,7 +5963,8 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 		return;
 
 	ret_val = e1000_read_nvm(hw, NVM_INIT_CONTROL2_REG, 1, &buf);
-	if (!ret_val && (!(le16_to_cpu(buf) & (1 << 0)))) {
+	le16_to_cpus(&buf);
+	if (!ret_val && (!(buf & (1 << 0)))) {
 		/* Deep Smart Power Down (DSPD) */
 		dev_warn(&adapter->pdev->dev,
 			 "Warning: detected DSPD enabled in EEPROM\n");
-- 
1.7.7.6
