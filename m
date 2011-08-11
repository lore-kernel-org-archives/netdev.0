From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] e1000e: alternate MAC address update
Date: Thu, 11 Aug 2011 15:31:47 -0700
Message-ID: <1313101908-11622-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53658 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733Ab1HKWbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 18:31:53 -0400
In-Reply-To: <1313101908-11622-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

If word 0x37 in the EEPROM is 0xFFFF _or_ 0x0000, then there is no
alternate MAC address in the EEPROM.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/lib.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 58af091..0893ab1 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -201,10 +201,10 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
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
1.7.6

