From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbe: write flush vfta registers
Date: Wed, 16 Nov 2016 20:40:41 +0800
Message-ID: <1479300041-3436-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [111.196.90.44] ([111.196.90.44]:34848 "EHLO mail.rain.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752715AbcKPM6T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 07:58:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

Sometimes vfta registers can not be written successfully in dcb mode.
This is very occassional. When the ixgbe nic runs for a very long time,
sometimes this bug occurs. But after IXGBE_WRITE_FLUSH is executed,
this bug never occurs.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bd93d82..1221cfb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4138,8 +4138,10 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
 	}
 
 	/* Set all bits in the VLAN filter table array */
-	for (i = hw->mac.vft_size; i--;)
+	for (i = hw->mac.vft_size; i--;) {
 		IXGBE_WRITE_REG(hw, IXGBE_VFTA(i), ~0U);
+		IXGBE_WRITE_FLUSH(hw);
+	}
 }
 
 #define VFTA_BLOCK_SIZE 8
@@ -4186,6 +4188,7 @@ static void ixgbe_scrub_vfta(struct ixgbe_adapter *adapter, u32 vfta_offset)
 		vfta[i] |= adapter->active_vlans[word] >> bits;
 
 		IXGBE_WRITE_REG(hw, IXGBE_VFTA(vfta_offset + i), vfta[i]);
+		IXGBE_WRITE_FLUSH(hw);
 	}
 }
 
-- 
2.7.4
