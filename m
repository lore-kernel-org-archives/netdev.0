From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] igb: Alternate MAC Address Updates for Func2&3
Date: Thu,  6 Oct 2011 04:02:39 -0700
Message-ID: <1317898959-16550-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30733 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935741Ab1JFLCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:47 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

Only function 1 has support for Alternate MAC Address in the EEPROM before,
this update now allow function 2 and 3 to have support for Alternate MAC
Address in the EEPROM.

Signed-off-by: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 7907183..872119d 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -205,6 +205,11 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 
 	if (hw->bus.func == E1000_FUNC_1)
 		nvm_alt_mac_addr_offset += E1000_ALT_MAC_ADDRESS_OFFSET_LAN1;
+	if (hw->bus.func == E1000_FUNC_2)
+		nvm_alt_mac_addr_offset += E1000_ALT_MAC_ADDRESS_OFFSET_LAN2;
+
+	if (hw->bus.func == E1000_FUNC_3)
+		nvm_alt_mac_addr_offset += E1000_ALT_MAC_ADDRESS_OFFSET_LAN3;
 	for (i = 0; i < ETH_ALEN; i += 2) {
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
 		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
-- 
1.7.6.4
