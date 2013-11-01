From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] igb: Don't let ethtool try to write to iNVM in i210/i211
Date: Fri,  1 Nov 2013 06:56:47 -0700
Message-ID: <1383314210-24289-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12204 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182Ab3KAN4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 09:56:55 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Fujinaka, Todd" <todd.fujinaka@intel.com>

Don't let ethtool try to write to iNVM in i210/i211.

This fixes an issue seen by Marek Vasut.

Reported-by: Marek Vasut <marex@denx.de>
Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 0ae3177..b918ba3 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -771,8 +771,10 @@ static int igb_set_eeprom(struct net_device *netdev,
 	if (eeprom->len == 0)
 		return -EOPNOTSUPP;
 
-	if (hw->mac.type == e1000_i211)
+	if ((hw->mac.type >= e1000_i210) &&
+	    !igb_get_flash_presence_i210(hw)) {
 		return -EOPNOTSUPP;
+	}
 
 	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
 		return -EFAULT;
-- 
1.8.3.1
