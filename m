From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] fm10k: Correctly set the number of Tx queues
Date: Thu,  2 Oct 2014 03:16:27 -0700
Message-ID: <1412244994-23636-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbaJBKQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:40 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The number of Tx queues was not being updated due to some issues when
generating the patches.  This change makes sure to add the lines necessary
to update the number of Tx queues correctly.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index dcec000..bf44a8f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -546,6 +546,10 @@ int fm10k_open(struct net_device *netdev)
 	fm10k_request_glort_range(interface);
 
 	/* Notify the stack of the actual queue counts */
+	err = netif_set_real_num_tx_queues(netdev,
+					   interface->num_tx_queues);
+	if (err)
+		goto err_set_queues;
 
 	err = netif_set_real_num_rx_queues(netdev,
 					   interface->num_rx_queues);
@@ -601,7 +605,7 @@ int fm10k_close(struct net_device *netdev)
 static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
-	unsigned int r_idx = 0;
+	unsigned int r_idx = skb->queue_mapping;
 	int err;
 
 	if ((skb->protocol ==  htons(ETH_P_8021Q)) &&
-- 
1.9.3
