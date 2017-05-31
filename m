From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] ixgbe: enable L3/L4 filtering for Tx switched packets
Date: Wed, 31 May 2017 14:19:25 -0700
Message-ID: <20170531211936.63417-5-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:4561 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750970AbdEaVTt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:49 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This will ensure that VF-to-VF traffic on the same PF
is filtered to allow RSS operation.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4f9679494b6c..7baca05c4a51 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3803,6 +3803,9 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 				mrqc = IXGBE_MRQC_VMDQRSS32EN;
 			else
 				mrqc = IXGBE_MRQC_VMDQRSS64EN;
+
+			/* Enable L3/L4 for Tx Switched packets */
+			mrqc |= IXGBE_MRQC_L3L4TXSWEN;
 		} else {
 			if (tcs > 4)
 				mrqc = IXGBE_MRQC_RTRSS8TCEN;
-- 
2.12.2
