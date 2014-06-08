From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: clear pxe after adminq is rebuilt
Date: Sun,  8 Jun 2014 07:33:51 -0700
Message-ID: <1402238037-20661-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64921 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536AbaFHOeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:06 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Be sure to clear PXE mode bit on each reset after AdminQ has been rebuilt.

Change-ID: I992d8c79594f8ca0660c50844ace675ecb9c9bf2
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8ab3c88..a8c9612 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5520,6 +5520,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 		i40e_verify_eeprom(pf);
 	}
 
+	i40e_clear_pxe_mode(hw);
 	ret = i40e_get_capabilities(pf);
 	if (ret) {
 		dev_info(&pf->pdev->dev, "i40e_get_capabilities failed, %d\n",
-- 
1.9.3
