From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Do not set skb ignore_df
Date: Fri,  2 Jan 2015 10:27:28 -0800
Message-ID: <1420223248-1681-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:55229 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751018AbbABS1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 13:27:34 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so23888999pdb.24
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 10:27:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnel transmit code clear this bit, so setting ignore_df has
no effect.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-geneve.c |    1 -
 net/openvswitch/vport-gre.c    |    2 --
 net/openvswitch/vport-vxlan.c  |    2 --
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 484864d..8769be9 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -209,7 +209,6 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 	sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
 	tunnel_id_to_vni(tun_key->tun_id, vni);
-	skb->ignore_df = 1;
 
 	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
 			      tun_key->ipv4_dst, tun_key->ipv4_tos,
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index d4168c4..ec57221 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -194,8 +194,6 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
 
-	skb->ignore_df = 1;
-
 	return iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
 			     tun_key->ipv4_dst, IPPROTO_GRE,
 			     tun_key->ipv4_tos, tun_key->ipv4_ttl, df, false);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d7c46b3..dc6f625 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -175,8 +175,6 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ?
 		htons(IP_DF) : 0;
 
-	skb->ignore_df = 1;
-
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
-- 
1.7.1
