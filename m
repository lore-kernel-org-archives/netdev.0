From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/18] i40e: Skip the priority tagging if DCB is not enabled
Date: Sat, 28 Feb 2015 03:29:35 -0800
Message-ID: <1425122989-354-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbbB1L3y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:54 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

If DCB is not enabled priority tagging is not needed
so skip over that section.

Change-ID: Ia3f3fa07945b421259a9ca38329d6d1cbd6c6bcc
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f8c863b..352dafe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2043,6 +2043,9 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 		tx_flags |= I40E_TX_FLAGS_SW_VLAN;
 	}
 
+	if (!(tx_ring->vsi->back->flags & I40E_FLAG_DCB_ENABLED))
+		goto out;
+
 	/* Insert 802.1p priority into VLAN header */
 	if ((tx_flags & (I40E_TX_FLAGS_HW_VLAN | I40E_TX_FLAGS_SW_VLAN)) ||
 	    (skb->priority != TC_PRIO_CONTROL)) {
@@ -2063,6 +2066,8 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 			tx_flags |= I40E_TX_FLAGS_HW_VLAN;
 		}
 	}
+
+out:
 	*flags = tx_flags;
 	return 0;
 }
-- 
1.9.3
