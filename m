From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: fix flags declaration
Date: Mon,  9 Oct 2017 15:38:28 -0700
Message-ID: <20171009223841.2557-2-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36088 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754085AbdJIWjF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:05 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since we don't yet have more than 32 flags, we'll use a u32 for both the
hw_features and flag field. Should we gain more flags in the future, we
may need to convert to a u64 or separate flags out into two fields.

This was overlooked in the previous commit 2781de2134c4 ("i40e/i40evf:
organize and re-number feature flags"), where the feature flag was not
converted form u64 to u32.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 18c453a3e728..7baf6d8a84dd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -424,7 +424,7 @@ struct i40e_pf {
 #define I40E_HW_PORT_ID_VALID			BIT(17)
 #define I40E_HW_RESTART_AUTONEG			BIT(18)
 
-	u64 flags;
+	u32 flags;
 #define I40E_FLAG_RX_CSUM_ENABLED		BIT(0)
 #define I40E_FLAG_MSI_ENABLED			BIT(1)
 #define I40E_FLAG_MSIX_ENABLED			BIT(2)
-- 
2.14.2
