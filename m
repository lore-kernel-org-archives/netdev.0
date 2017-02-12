From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: update comment explaining where FDIR buffers are freed
Date: Sat, 11 Feb 2017 21:30:20 -0800
Message-ID: <20170212053028.98581-7-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:18297 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750714AbdBLFac (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:32 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The original comment implies that the only location where the raw_packet
buffer will be freed is in i40e_clean_tx_ring() which is incorrect. In
fact this isn't even the normal case. Update the comment explaining
where the memory is freed.

Change-ID: Ie0defc35ed1c3af183f81fdc60b6d783707a5595
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 1202b4c7..09f09ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -432,7 +432,12 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 		ret = -EINVAL;
 	}
 
-	/* The buffer allocated here is freed by the i40e_clean_tx_ring() */
+	/* The buffer allocated here will be normally be freed by
+	 * i40e_clean_fdir_tx_irq() as it reclaims resources after transmit
+	 * completion. In the event of an error adding the buffer to the FDIR
+	 * ring, it will immediately be freed. It may also be freed by
+	 * i40e_clean_tx_ring() when closing the VSI.
+	 */
 	return ret;
 }
 
-- 
2.10.2
