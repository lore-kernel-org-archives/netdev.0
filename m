From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] VLAN code can use the faster ether_compare_addr
Date: Fri, 14 Jul 2006 14:27:38 -0700
Message-ID: <20060714142738.265a7a98@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5788 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161305AbWGNV1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 17:27:54 -0400
To: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The inline function compare_ether_addr is faster than memcmp.
Also, don't need to drag in proc_fs.h, the only reference to proc_dir_entry
is a pointer so the declaration is needed here.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 include/linux/if_vlan.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

1738bd3d785bb3f9fa24e26f98b8d86e7783eadf
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index eef0876..383627a 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -23,8 +23,8 @@ struct vlan_collection;
 struct vlan_dev_info;
 struct hlist_node;
 
-#include <linux/proc_fs.h> /* for proc_dir_entry */
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 
 #define VLAN_HLEN	4		/* The additional bytes (on top of the Ethernet header)
 					 * that VLAN requires.
@@ -185,7 +185,8 @@ static inline int __vlan_hwaccel_rx(stru
 		 * This allows the VLAN to have a different MAC than the underlying
 		 * device, and still route correctly.
 		 */
-		if (!memcmp(eth_hdr(skb)->h_dest, skb->dev->dev_addr, ETH_ALEN))
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+				       	skb->dev->dev_addr))
 			skb->pkt_type = PACKET_HOST;
 		break;
 	};
-- 
1.2.4

