From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e/i40evf: Add call to u64_stats_init to init
Date: Mon,  9 Feb 2015 02:44:01 -0800
Message-ID: <1423478641-3138-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760656AbbBIKoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:07 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a call to u64_stats_init to Rx setup.
This done in order to avoid lockdep errors with seqcount on newer kernels.

Change-ID: Ia8ba8f0bcbd1c0e926f97d70aeee4ce4fd055e93
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 ++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5aa6ef1..f4d6d90 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1098,6 +1098,8 @@ int i40e_setup_rx_descriptors(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		goto err;
 
+		u64_stats_init(rx_ring->syncp);
+
 	/* Round up to nearest 4K */
 	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
 		? rx_ring->count * sizeof(union i40e_16byte_rx_desc)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 4bf15da..459499a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -596,6 +596,8 @@ int i40evf_setup_rx_descriptors(struct i40e_ring *rx_ring)
 	if (!rx_ring->rx_bi)
 		goto err;
 
+		u64_stats_init(rx_ring->syncp);
+
 	/* Round up to nearest 4K */
 	rx_ring->size = ring_is_16byte_desc_enabled(rx_ring)
 		? rx_ring->count * sizeof(union i40e_16byte_rx_desc)
-- 
1.9.3
