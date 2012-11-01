From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] igb: Fix EEPROM writes via ethtool on i210
Date: Thu,  1 Nov 2012 03:44:26 -0700
Message-ID: <1351766667-28489-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1625 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757765Ab2KAKod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 06:44:33 -0400
In-Reply-To: <1351766667-28489-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where the driver would crash when trying to
write a word to the EEPROM on i210 devices.

Reported-by: Ekman Tsang <Ekman.Tsang@riverbed.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 4313bcc..deb0597 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -319,6 +319,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		nvm->ops.acquire = igb_acquire_nvm_i210;
 		nvm->ops.release = igb_release_nvm_i210;
 		nvm->ops.read    = igb_read_nvm_srrd_i210;
+		nvm->ops.write   = igb_write_nvm_srwr_i210;
 		nvm->ops.valid_led_default = igb_valid_led_default_i210;
 		break;
 	case e1000_i211:
-- 
1.7.11.7
