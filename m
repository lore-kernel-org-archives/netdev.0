From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 8/9] ipvlan: improve compiler hints
Date: Thu, 27 Apr 2017 15:51:41 +0100
Message-ID: <20170427145142.15830-9-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:44550 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936273AbdD0Ows (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:48 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend inlining and branch prediction hints.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index a9fc1b5..67e342d 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -88,7 +88,7 @@ void ipvlan_ht_addr_del(struct ipvl_addr *addr)
 	hlist_del_init_rcu(&addr->hlnode);
 }
 
-unsigned int ipvlan_mac_hash(const unsigned char *addr)
+inline unsigned int ipvlan_mac_hash(const unsigned char *addr)
 {
 	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
 			       ipvlan_jhash_secret);
@@ -505,7 +505,7 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 			return ipvlan_rcv_int_frame(addr, &skb);
 
 		skb = skb_share_check(skb, GFP_ATOMIC);
-		if (!skb)
+		if (unlikely(!skb))
 			return NET_XMIT_DROP;
 
 		/* Packet definitely does not belong to any of the
@@ -596,7 +596,7 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 			 * when work-queue processes this frame. This is
 			 * achieved by returning RX_HANDLER_PASS.
 			 */
-			if (nskb)
+			if (likely(nskb))
 				ipvlan_multicast_enqueue(port, nskb, false);
 		}
 	} else {
-- 
2.9.3

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
