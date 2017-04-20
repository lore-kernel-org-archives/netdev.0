From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e/i40evf: Remove VF Rx csum offload for tunneled packets
Date: Wed, 19 Apr 2017 18:57:38 -0700
Message-ID: <20170420015750.6828-3-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: alice michael <alice.michael@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Preethi Banala <preethi.banala@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:20804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939030AbdDTB54 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:57:56 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alice michael <alice.michael@intel.com>

Rx checksum offload for tunneled packets was never being negotiated or
requested by VF. This capability was assumed by default and enabled in
current hardware for VF. Going forward, this feature needs to be disabled
or advanced ptypes should be negotiated with PF in the future.

Change-ID: I9e54cfa8a90e03ab6956db4412f1e337ccd2c2e0
Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 460171edc412..fc4b14af370d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -831,13 +831,6 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	if (rx_error & BIT(I40E_RX_DESC_ERROR_PPRS_SHIFT))
 		return;
 
-	/* If there is an outer header present that might contain a checksum
-	 * we need to bump the checksum level by 1 to reflect the fact that
-	 * we are indicating we validated the inner checksum.
-	 */
-	if (decoded.tunnel_type >= I40E_RX_PTYPE_TUNNEL_IP_GRENAT)
-		skb->csum_level = 1;
-
 	/* Only report checksum unnecessary for TCP, UDP, or SCTP */
 	switch (decoded.inner_prot) {
 	case I40E_RX_PTYPE_INNER_PROT_TCP:
-- 
2.12.2
