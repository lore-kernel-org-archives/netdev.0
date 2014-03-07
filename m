From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] vlan: use use ether_addr_equal_64bits to instead of ether_addr_equal
Date: Fri, 7 Mar 2014 18:45:31 +0800
Message-ID: <1394189131-3916-3-git-send-email-dingtianhong@huawei.com>
References: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <julia.lawall@lip6.fr>, <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:59873 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbaCGKp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:45:59 -0500
In-Reply-To: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
can be used when each argument is an array within a structure that
contains at least two bytes of data beyond the array, so it is safe
to use it for vlan, and make sense for fast path.

Cc: Joe Perches <joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlan_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 97815ec..35b3c19 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -26,7 +26,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		/* Our lower layer thinks this is not local, let's make sure.
 		 * This allows the VLAN to have a different MAC than the
 		 * underlying device, and still route correctly. */
-		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
+		if (ether_addr_equal_64bits(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
 			skb->pkt_type = PACKET_HOST;
 	}
 
-- 
1.8.0
