From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: fix the FWSM.PT check in ixgbe_mng_present()
Date: Mon,  9 Oct 2017 11:39:58 -0700
Message-ID: <20171009184000.80053-9-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54649 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755235AbdJISkY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:24 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Bits other than FWSM.PT can be set in IXGBE_SWFW_MODE_MASK making the
previous check invalid.

Change the check for MNG present to be only based on FWSM.PT bit.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 041940c4bb2b..4e5c92dea869 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -4100,8 +4100,8 @@ bool ixgbe_mng_present(struct ixgbe_hw *hw)
 		return false;
 
 	fwsm = IXGBE_READ_REG(hw, IXGBE_FWSM(hw));
-	fwsm &= IXGBE_FWSM_MODE_MASK;
-	return fwsm == IXGBE_FWSM_FW_MODE_PT;
+
+	return !!(fwsm & IXGBE_FWSM_FW_MODE_PT);
 }
 
 /**
-- 
2.14.2
