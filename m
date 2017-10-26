From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/6] i40e: Fix incorrect use of tx_itr_setting when checking for Rx ITR setup
Date: Thu, 26 Oct 2017 09:19:54 -0700
Message-ID: <20171026161955.4407-6-jeffrey.t.kirsher@intel.com>
References: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [134.134.136.20] ([134.134.136.20]:55616 "EHLO mga02.intel.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S932426AbdJZQUS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:20:18 -0400
In-Reply-To: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

It looks like there was either a copy/paste error or just a typo that
resulted in the Tx ITR setting being used to determine if we were using
adaptive Rx interrupt moderation or not.

This patch fixes the typo.

Fixes: 65e87c0398f5 ("i40evf: support queue-specific settings for interrupt moderation")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 2756131495f0..ab142e05e196 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2269,7 +2269,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 		goto enable_int;
 	}
 
-	if (ITR_IS_DYNAMIC(tx_itr_setting)) {
+	if (ITR_IS_DYNAMIC(rx_itr_setting)) {
 		rx = i40e_set_new_dynamic_itr(&q_vector->rx);
 		rxval = i40e_buildreg_itr(I40E_RX_ITR, q_vector->rx.itr);
 	}
-- 
2.14.2
