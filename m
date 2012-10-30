From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] ixgbevf: Do not forward LLDP type frames
Date: Tue, 30 Oct 2012 00:04:26 -0700
Message-ID: <1351580670-8292-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25412 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755300Ab2J3HEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:04:37 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The driver should not forward LLDP type frames.  Inspect the ether type and
do not send if it is an LLDP ethertype frame.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 07d7eab..b5979ba 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2968,6 +2968,11 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 #if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
 	unsigned short f;
 #endif
+	u8 *dst_mac = skb_header_pointer(skb, 0, 0, NULL);
+	if (!dst_mac || is_link_local(dst_mac)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 
 	tx_ring = &adapter->tx_ring[r_idx];
 
-- 
1.7.11.7
