From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] openvswitch: Only set TUNNEL_VXLAN_OPT if VXLAN-GBP metadata is set
Date: Mon,  9 Feb 2015 16:56:37 +0100
Message-ID: <27de6976a7a40d1da2875b93138353724cbfa24b.1423497309.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53764 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759408AbbBIP4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 10:56:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids setting TUNNEL_VXLAN_OPT for VXLAN frames which don't
have any GBP metadata set. It is not invalid to set it but unnecessary.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/vport-vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index ff07d40..3277a75 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -76,7 +76,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 
 	flags = TUNNEL_KEY | (udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0);
 	vxlan_port = vxlan_vport(vport);
-	if (vxlan_port->exts & VXLAN_F_GBP)
+	if (vxlan_port->exts & VXLAN_F_GBP && md->gbp)
 		flags |= TUNNEL_VXLAN_OPT;
 
 	/* Save outer tunnel values */
-- 
1.9.3
