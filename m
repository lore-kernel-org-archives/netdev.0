From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] i40e: Bit test mask correction
Date: Sat, 29 Oct 2016 00:30:44 -0700
Message-ID: <1477726258-111563-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Filip Sadowski <filip.sadowski@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10260 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752213AbcJ2HbI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:08 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filip Sadowski <filip.sadowski@intel.com>

Incorrect bit mask was used for testing "get link status" response.
Instead of I40E_AQ_LSE_ENABLE (which is actually 0x03) it most probably
should be I40E_AQ_LSE_IS_ENABLED (which is defined as 0x01).

Change-ID: Ia199142906720507f847de3a33a25c61a9781b2f
Signed-off-by: Filip Sadowski <filip.sadowski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2154a34..fe8100b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1849,7 +1849,7 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 	else
 		hw_link_info->crc_enable = false;
 
-	if (resp->command_flags & cpu_to_le16(I40E_AQ_LSE_ENABLE))
+	if (resp->command_flags & cpu_to_le16(I40E_AQ_LSE_IS_ENABLED))
 		hw_link_info->lse_enable = true;
 	else
 		hw_link_info->lse_enable = false;
-- 
2.7.4
