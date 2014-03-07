From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] vlan: slight optimization for vlan_do_receive()
Date: Fri, 7 Mar 2014 18:45:30 +0800
Message-ID: <1394189131-3916-2-git-send-email-dingtianhong@huawei.com>
References: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <julia.lawall@lip6.fr>, <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:59878 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaCGKp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 05:45:59 -0500
In-Reply-To: <1394189131-3916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According Joe's suggestion, maybe it'd be faster to add an unlikely to
the test for PCKET_OTHERHOST, so I add it and see whether the performance
could be better, although the differences is so small and negligible, but
it is hard to catch that any lower device would set the skb type to
PACKET_OTHERHOST, so most of time, I think it make sense to add unlikely
for the test.

Cc: Joe Perches <joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlan_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 6ee48aa..97815ec 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -22,7 +22,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		return false;
 
 	skb->dev = vlan_dev;
-	if (skb->pkt_type == PACKET_OTHERHOST) {
+	if (unlikely(skb->pkt_type == PACKET_OTHERHOST)) {
 		/* Our lower layer thinks this is not local, let's make sure.
 		 * This allows the VLAN to have a different MAC than the
 		 * underlying device, and still route correctly. */
-- 
1.8.0
