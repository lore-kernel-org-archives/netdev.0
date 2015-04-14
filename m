From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/25] fm10k: only show actual queues, not the maximum in hardware
Date: Tue, 14 Apr 2015 16:50:54 -0700
Message-ID: <1429055471-401-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20409 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417AbbDNXvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:19 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we show statistics for all 128 queues, even though we don't
necessarily have that many queues available especially in the VF case.
Instead, use the hw->mac.max_queues value, which tells us how many
queues we actually have, rather than the space for the rings we
allocated. In this way, we prevent dumping statistics that are useless
on the VF.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 697a269..478e67b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -118,6 +118,7 @@ enum fm10k_self_test_types {
 
 static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
+	struct fm10k_intfc *interface = netdev_priv(dev);
 	char *p = (char *)data;
 	int i;
 
@@ -138,7 +139,7 @@ static void fm10k_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 			p += ETH_GSTRING_LEN;
 		}
 
-		for (i = 0; i < MAX_QUEUES; i++) {
+		for (i = 0; i < interface->hw.mac.max_queues; i++) {
 			sprintf(p, "tx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "tx_queue_%u_bytes", i);
@@ -188,7 +189,7 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 
-	for (i = 0; i < MAX_QUEUES; i++) {
+	for (i = 0; i < interface->hw.mac.max_queues; i++) {
 		struct fm10k_ring *ring;
 		u64 *queue_stat;
 
-- 
1.9.3
