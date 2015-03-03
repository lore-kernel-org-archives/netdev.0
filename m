From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/17] i40e: Skip the priority tagging if DCB is not enabled
Date: Tue,  3 Mar 2015 01:44:11 -0800
Message-ID: <1425375864-25117-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:10578 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbbCCJob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 04:44:31 -0500
In-Reply-To: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
