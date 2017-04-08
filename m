From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] i40e: Swap use of pf->flags and pf->hw_disabled_flags for ATR Eviction
Date: Sat,  8 Apr 2017 02:55:44 -0700
Message-ID: <20170408095553.78307-4-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25320 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751764AbdDHJ4A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:56:00 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is a minor cleanup so that we are always updating pf->flags when we
make a change to the private flags instead of updating a mix of either
pf->flags and/or pf->hw_disabled_flags.

In addition I went through and cleaned out all the spots where we were
using the X722 define in regards to this flag.

Lastly since we changed the logic I went through and flushed out any
redundancy and cleaned up the handling of the flags in the Tx path.

Change-ID: I79ff95a7272bb2533251ff11ef91e89ccb80b610
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d45f48c84ff7..a9a97dd2c0a5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2263,8 +2263,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	/* Due to lack of space, no more new filters can be programmed */
 	if (th->syn && (pf->hw_disabled_flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
-	if ((pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) &&
-	    (!(pf->hw_disabled_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))) {
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) {
 		/* HW ATR eviction will take care of removing filters on FIN
 		 * and RST packets.
 		 */
@@ -2326,8 +2325,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
 			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
-	if ((pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) &&
-	    (!(pf->hw_disabled_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)))
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
 		dtype_cmd |= I40E_TXD_FLTR_QW1_ATR_MASK;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
-- 
2.12.2
