From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] igb: Alternate MAC Address EEPROM Updates
Date: Thu,  6 Oct 2011 04:02:38 -0700
Message-ID: <1317898959-16550-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40603 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935643Ab1JFLCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:47 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This code check word 0x37 in the EEPROM, if it is 0xFFFF _or_ 0x0000, then
there is no Alternate MAC Address in the EEPROM.

Signed-off-by: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 2b5ef76..7907183 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -198,10 +198,10 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 		goto out;
 	}
 
-	if (nvm_alt_mac_addr_offset == 0xFFFF) {
+	if ((nvm_alt_mac_addr_offset == 0xFFFF) ||
+	    (nvm_alt_mac_addr_offset == 0x0000))
 		/* There is no Alternate MAC Address */
 		goto out;
-	}
 
 	if (hw->bus.func == E1000_FUNC_1)
 		nvm_alt_mac_addr_offset += E1000_ALT_MAC_ADDRESS_OFFSET_LAN1;
-- 
1.7.6.4
