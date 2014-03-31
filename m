From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: Remove casts of pointer to same type
Date: Mon, 31 Mar 2014 16:34:56 -0700
Message-ID: <1396308899-20926-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2042 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbaCaXga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 19:36:30 -0400
In-Reply-To: <1396308899-20926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Casting a pointer to a pointer of the same type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast_2.cocci
@@
type T;
T *foo;
@@

-	(T *)foo
+	foo

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index aa123f4..03d99cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -396,7 +396,7 @@ static int i40e_get_eeprom(struct net_device *netdev,
 		ret_val = i40e_aq_read_nvm(hw, 0x0,
 				eeprom->offset + (I40E_NVM_SECTOR_SIZE * i),
 				len,
-				(u8 *)eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
+				eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
 				last, NULL);
 		if (ret_val) {
 			dev_info(&pf->pdev->dev,
@@ -408,7 +408,7 @@ static int i40e_get_eeprom(struct net_device *netdev,
 
 release_nvm:
 	i40e_release_nvm(hw);
-	memcpy(bytes, (u8 *)eeprom_buff, eeprom->len);
+	memcpy(bytes, eeprom_buff, eeprom->len);
 free_buff:
 	kfree(eeprom_buff);
 	return ret_val;
-- 
1.9.0
