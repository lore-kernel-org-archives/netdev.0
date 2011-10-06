From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] igb: Code to prevent overwriting SFP I2C
Date: Thu,  6 Oct 2011 04:02:37 -0700
Message-ID: <1317898959-16550-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62105 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935422Ab1JFLCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:46 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch fixes "overwrite" problem. without this fix, SFP I2C EEPROM
data, which is located at A0 can be overwritten by the phy write function.

Signed-off-by: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index e662554..7edf31e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -306,6 +306,12 @@ s32 igb_write_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 data)
 	u32 i, i2ccmd = 0;
 	u16 phy_data_swapped;
 
+	/* Prevent overwritting SFP I2C EEPROM which is at A0 address.*/
+	if ((hw->phy.addr == 0) || (hw->phy.addr > 7)) {
+		hw_dbg("PHY I2C Address %d is out of range.\n",
+			  hw->phy.addr);
+		return -E1000_ERR_CONFIG;
+	}
 
 	/* Swap the data bytes for the I2C interface */
 	phy_data_swapped = ((data >> 8) & 0x00FF) | ((data << 8) & 0xFF00);
-- 
1.7.6.4
