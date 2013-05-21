From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] igb: Implementation of i210/i211 LED support
Date: Tue, 21 May 2013 15:03:18 -0700
Message-ID: <1369173800-20326-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2239 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299Ab3EUWDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:33 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch fixes LED issues with i210 and i211 devices, due to changes in the
device registers.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_i210.h | 6 +++---
 drivers/net/ethernet/intel/igb/e1000_mac.c  | 8 +++++++-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.h b/drivers/net/ethernet/intel/igb/e1000_i210.h
index bfc08e0..5caa332 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.h
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.h
@@ -82,11 +82,11 @@ enum E1000_INVM_STRUCTURE_TYPE {
 #define E1000_INVM_MAJOR_SHIFT		4
 
 #define ID_LED_DEFAULT_I210		((ID_LED_OFF1_ON2  << 8) | \
-					 (ID_LED_OFF1_OFF2 <<  4) | \
-					 (ID_LED_DEF1_DEF2))
+					 (ID_LED_DEF1_DEF2 <<  4) | \
+					 (ID_LED_OFF1_OFF2))
 #define ID_LED_DEFAULT_I210_SERDES	((ID_LED_DEF1_DEF2 << 8) | \
 					 (ID_LED_DEF1_DEF2 <<  4) | \
-					 (ID_LED_DEF1_DEF2))
+					 (ID_LED_OFF1_ON2))
 
 /* NVM offset defaults for i211 device */
 #define NVM_INIT_CTRL_2_DEFAULT_I211	0X7243
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 660b7ad..bab556a 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1332,7 +1332,13 @@ s32 igb_id_led_init(struct e1000_hw *hw)
 	u16 data, i, temp;
 	const u16 led_mask = 0x0F;
 
-	ret_val = igb_valid_led_default(hw, &data);
+	/* i210 and i211 devices have different LED mechanism */
+	if ((hw->mac.type == e1000_i210) ||
+	    (hw->mac.type == e1000_i211))
+		ret_val = igb_valid_led_default_i210(hw, &data);
+	else
+		ret_val = igb_valid_led_default(hw, &data);
+
 	if (ret_val)
 		goto out;
 
-- 
1.7.11.7
