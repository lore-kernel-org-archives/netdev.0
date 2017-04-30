From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40evf: remove I40E_FLAG_FDIR_ATR_ENABLED
Date: Sun, 30 Apr 2017 06:24:49 -0700
Message-ID: <20170430132451.68494-12-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:53521 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164412AbdD3NZL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:25:11 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The flag used by the common code and PF code is I40E_FLAG_FD_ATR_ENABLED,
not *FDIR*. It turns out none of the txrx code actually shared with the
VF driver actually checks the ATR flag. This is made even more obvious
by the typo in the VF header file.

Let's just remove the flag from the VF driver since it's not needed.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 4681c63ee7e3..b8ada6d8d890 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -223,7 +223,6 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_ALLMULTI_ON			BIT(19)
 #define I40EVF_FLAG_LEGACY_RX			BIT(20)
 /* duplicates for common code */
-#define I40E_FLAG_FDIR_ATR_ENABLED		0
 #define I40E_FLAG_DCB_ENABLED			0
 #define I40E_FLAG_RX_CSUM_ENABLED		I40EVF_FLAG_RX_CSUM_ENABLED
 #define I40E_FLAG_WB_ON_ITR_CAPABLE		I40EVF_FLAG_WB_ON_ITR_CAPABLE
-- 
2.12.2
