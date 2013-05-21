From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] igb: Fix set_ethtool function to call update nvm for entire image
Date: Tue, 21 May 2013 15:03:16 -0700
Message-ID: <1369173800-20326-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24090 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753376Ab3EUWDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:32 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where we were only checking to update checksum
on first part of nvm image.  Newer parts have multiple checksum fields and
checksum function will accommodate that as long as we call it in the first
place for any changes made.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 7b25ee2..85fe7b5 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -811,10 +811,8 @@ static int igb_set_eeprom(struct net_device *netdev,
 	ret_val = hw->nvm.ops.write(hw, first_word,
 				    last_word - first_word + 1, eeprom_buff);
 
-	/* Update the checksum over the first part of the EEPROM if needed
-	 * and flush shadow RAM for 82573 controllers
-	 */
-	if ((ret_val == 0) && ((first_word <= NVM_CHECKSUM_REG)))
+	/* Update the checksum if nvm write succeeded */
+	if (ret_val == 0)
 		hw->nvm.ops.update(hw);
 
 	igb_set_fw_version(adapter);
-- 
1.7.11.7
