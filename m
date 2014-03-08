From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] igb: fix array size calculation
Date: Sat,  8 Mar 2014 01:25:40 -0800
Message-ID: <1394270741-29926-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39895 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbaCHJ0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:26:03 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Use ARRAY_SIZE for array size calculation.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 45947b3..1da4e87 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -76,8 +76,6 @@ static s32 igb_update_nvm_checksum_i350(struct e1000_hw *hw);
 static const u16 e1000_82580_rxpbs_table[] =
 	{ 36, 72, 144, 1, 2, 4, 8, 16,
 	  35, 70, 140 };
-#define E1000_82580_RXPBS_TABLE_SIZE \
-	(sizeof(e1000_82580_rxpbs_table)/sizeof(u16))
 
 /**
  *  igb_sgmii_uses_mdio_82575 - Determine if I2C pins are for external MDIO
@@ -2307,7 +2305,7 @@ u16 igb_rxpbs_adjust_82580(u32 data)
 {
 	u16 ret_val = 0;
 
-	if (data < E1000_82580_RXPBS_TABLE_SIZE)
+	if (data < ARRAY_SIZE(e1000_82580_rxpbs_table))
 		ret_val = e1000_82580_rxpbs_table[data];
 
 	return ret_val;
-- 
1.8.3.1
