From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] net: e1000e calls skb_set_hash
Date: Tue, 11 Mar 2014 22:53:26 -0700
Message-ID: <1394603618-1044-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753989AbaCLFxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:40 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

Drivers should call skb_set_hash to set the hash and its type
in an skbuff.

Signed-off-by: Tom Herbert <therbert@google.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 5129c4c..3f044e7 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -878,7 +878,7 @@ static inline void e1000_rx_hash(struct net_device *netdev, __le32 rss,
 				 struct sk_buff *skb)
 {
 	if (netdev->features & NETIF_F_RXHASH)
-		skb->rxhash = le32_to_cpu(rss);
+		skb_set_hash(skb, le32_to_cpu(rss), PKT_HASH_TYPE_L3);
 }
 
 /**
-- 
1.8.3.1
