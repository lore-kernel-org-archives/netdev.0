From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] openvswitch: Retrieve tunnel metadata when receiving from vport-netdev
Date: Thu, 23 Jul 2015 13:04:44 +0200
Message-ID: <f91747edf4825bd5b6641c5c815d0e20f59b7a3a.1437649446.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:60744 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbGWLEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 07:04:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Retrieve the tunnel metadata for packets received by a net_device and
provide it to ovs_vport_receive() for flow key extraction.

[This hunk was in the GRE patch in the initial series and missed the
 cut for the initial submission for merging.]

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/vport-netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 68d0582..2254b74 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -58,7 +58,7 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 	skb_push(skb, ETH_HLEN);
 	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
 
-	ovs_vport_receive(vport, skb, NULL);
+	ovs_vport_receive(vport, skb, skb_tunnel_info(skb, AF_INET));
 	return;
 
 error:
-- 
2.4.3
