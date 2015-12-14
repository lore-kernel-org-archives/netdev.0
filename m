From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] fm10k: use ether_addr_copy to copy MAC address
Date: Sun, 13 Dec 2015 16:27:33 -0800
Message-ID: <1450052867-36654-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551AbbLNA1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 19:27:49 -0500
In-Reply-To: <1450052867-36654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Use the ether_addr_copy function instead of copying byte-by-byte in a
for-loop by hand.

Reported-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index 8b9b6ba..bbf0b4a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -266,7 +266,6 @@ static s32 fm10k_read_mac_addr_pf(struct fm10k_hw *hw)
 {
 	u8 perm_addr[ETH_ALEN];
 	u32 serial_num;
-	int i;
 
 	serial_num = fm10k_read_reg(hw, FM10K_SM_AREA(1));
 
@@ -288,10 +287,8 @@ static s32 fm10k_read_mac_addr_pf(struct fm10k_hw *hw)
 	perm_addr[4] = (u8)(serial_num >> 8);
 	perm_addr[5] = (u8)(serial_num);
 
-	for (i = 0; i < ETH_ALEN; i++) {
-		hw->mac.perm_addr[i] = perm_addr[i];
-		hw->mac.addr[i] = perm_addr[i];
-	}
+	ether_addr_copy(hw->mac.perm_addr, perm_addr);
+	ether_addr_copy(hw->mac.addr, perm_addr);
 
 	return 0;
 }
-- 
2.5.0
