From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] i40evf: fix 32 bit build warnings
Date: Wed, 07 Oct 2015 22:13:19 +0200
Message-ID: <6607276.TY67sbLLqL@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: intel-wired-lan@lists.osuosl.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	kbuild-all@01.org, Andrew Bowers <andrewx.bowers@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:58901 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbbJGUNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 16:13:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Brandeburg fixed a bug for 32-bit systems in the i40e driver
in commit 9c70d7cebfec5 ("i40e: fix 32 bit build warnings"), but the
same code still exists in the i40evf driver and causes compilation
warnings in ARM and x86 allmodconfig:

drivers/net/ethernet/intel/i40evf/i40e_common.c:445:68: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
drivers/net/ethernet/intel/i40evf/i40e_common.c:446:71: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]

This applies the same fix by removing the broken code.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

---

It would probably be a good idea to merge some of the duplicate code into
a library module that gets used by both drivers to avoid having to fix bugs
twice in the future.

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 1950db10a414..92e180d9b86e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -442,9 +442,6 @@ static i40e_status i40e_aq_get_set_rss_lut(struct i40e_hw *hw,
 					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_SHIFT) &
 					I40E_AQC_SET_RSS_LUT_TABLE_TYPE_MASK));
 
-	cmd_resp->addr_high = cpu_to_le32(high_16_bits((u64)lut));
-	cmd_resp->addr_low = cpu_to_le32(lower_32_bits((u64)lut));
-
 	status = i40evf_asq_send_command(hw, &desc, lut, lut_size, NULL);
 
 	return status;
@@ -519,8 +516,6 @@ static i40e_status i40e_aq_get_set_rss_key(struct i40e_hw *hw,
 					  I40E_AQC_SET_RSS_KEY_VSI_ID_SHIFT) &
 					  I40E_AQC_SET_RSS_KEY_VSI_ID_MASK));
 	cmd_resp->vsi_id |= cpu_to_le16((u16)I40E_AQC_SET_RSS_KEY_VSI_VALID);
-	cmd_resp->addr_high = cpu_to_le32(high_16_bits((u64)key));
-	cmd_resp->addr_low = cpu_to_le32(lower_32_bits((u64)key));
 
 	status = i40evf_asq_send_command(hw, &desc, key, key_size, NULL);
 
