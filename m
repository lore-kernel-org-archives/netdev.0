From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/5] igb: Fix for Alt MAC Address feature on 82580 and later devices
Date: Fri, 21 Oct 2011 03:31:59 -0700
Message-ID: <1319193121-2729-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30637 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754133Ab1JUKcH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 06:32:07 -0400
In-Reply-To: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

In 82580 and later devices, the alternate MAC address feature is
completely handled by the option ROM and software does not handle
it anymore.  This patch changes the check_alt_mac_addr function to
exit immediately if device is 82580 or later.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 872119d..bad3e14 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -191,6 +191,13 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	u16 offset, nvm_alt_mac_addr_offset, nvm_data;
 	u8 alt_mac_addr[ETH_ALEN];
 
+	/*
+	 * Alternate MAC address is handled by the option ROM for 82580
+	 * and newer. SW support not required.
+	 */
+	if (hw->mac.type >= e1000_82580)
+		goto out;
+
 	ret_val = hw->nvm.ops.read(hw, NVM_ALT_MAC_ADDR_PTR, 1,
 				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
-- 
1.7.6.4
