From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000e: fix obscure comments
Date: Fri,  6 Mar 2015 03:06:01 -0800
Message-ID: <1425639966-6829-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John W Linville <linville@tuxdriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14541 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756049AbbCFLGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 06:06:11 -0500
In-Reply-To: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

The interface to the device flash was modified in i219 and later HW.
This patch better describes the change and the impact on the driver.

CC: John W Linville <linville@tuxdriver.com>
Reported-by: John W Linville <linville@tuxdriver.com>
Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 7523f51..9d81c03 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -603,12 +603,15 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 	u16 i;
 	u32 nvm_size;
 
-	/* Can't read flash registers if the register set isn't mapped. */
 	nvm->type = e1000_nvm_flash_sw;
-	/* in SPT, gfpreg doesn't exist. NVM size is taken from the
-	 * STRAP register
-	 */
+
 	if (hw->mac.type == e1000_pch_spt) {
+		/* in SPT, gfpreg doesn't exist. NVM size is taken from the
+		 * STRAP register. This is because in SPT the GbE Flash region
+		 * is no longer accessed through the flash registers. Instead,
+		 * the mechanism has changed, and the Flash region access
+		 * registers are now implemented in GbE memory space.
+		 */
 		nvm->flash_base_addr = 0;
 		nvm_size = (((er32(STRAP) >> 1) & 0x1F) + 1)
 		    * NVM_SIZE_MULTIPLIER;
@@ -618,6 +621,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 		/* Set the base address for flash register access */
 		hw->flash_address = hw->hw_addr + E1000_FLASH_BASE_ADDR;
 	} else {
+		/* Can't read flash registers if register set isn't mapped. */
 		if (!hw->flash_address) {
 			e_dbg("ERROR: Flash registers not mapped\n");
 			return -E1000_ERR_CONFIG;
-- 
1.9.3
