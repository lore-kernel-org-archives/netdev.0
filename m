From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH] net/openvswitch: Remove the skb encapsulation mark after decapsulation
Date: Wed, 22 Jan 2014 17:15:05 +0200
Message-ID: <1390403705-28690-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46445 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932122AbaAVPPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 10:15:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must unset the skb encapsulation mark before injecting the
decapsulated packet into ovs for the rest of its journey.

This follows the practice set by 0afb166 "vxlan: Add capability of Rx
checksum offload for inner packet" and the overall idea behind the
skb encapsulation field.

Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/openvswitch/vport-vxlan.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index e797a50..3742c71 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -68,6 +68,9 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 	key = cpu_to_be64(ntohl(vx_vni) >> 8);
 	ovs_flow_tun_key_init(&tun_key, iph, key, TUNNEL_KEY);
 
+	/* we must unset the encapsulation mark after decapsulation */
+	skb->encapsulation = 0;
+
 	ovs_vport_receive(vport, skb, &tun_key);
 }
 
-- 
1.7.1
