From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] openvswitch: set correct protocol on route lookup
Date: Fri,  5 Dec 2014 17:24:28 +0100
Message-ID: <0ead411e38bc57a8971ffd9826f7bf9bfdc6ccf1.1417796557.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Wenyu Zhang <wenyuz@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009AbaLEQ1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 11:27:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respect what the caller passed to ovs_tunnel_get_egress_info.

Fixes: 8f0aad6f35f7e ("openvswitch: Extend packet attribute for egress tunnel info")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/vport.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index e771a46933e5..9584526c0778 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -600,7 +600,7 @@ int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
 	fl.saddr = tun_key->ipv4_src;
 	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
 	fl.flowi4_mark = skb_mark;
-	fl.flowi4_proto = IPPROTO_GRE;
+	fl.flowi4_proto = ipproto;
 
 	rt = ip_route_output_key(net, &fl);
 	if (IS_ERR(rt))
-- 
1.8.3.1
