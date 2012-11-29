From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 1/7] openvswitch: Process RARP packets with ethertype 0x8035 similar to ARP packets.
Date: Thu, 29 Nov 2012 10:35:43 -0800
Message-ID: <1354214149-33651-2-git-send-email-jesse@nicira.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Mehak Mahajan <mmahajan@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:49445 "HELO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751100Ab2K2Sf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:35:58 -0500
Received: by mail-da0-f70.google.com with SMTP id t11so10204344daj.1
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:35:57 -0800 (PST)
In-Reply-To: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mehak Mahajan <mmahajan@nicira.com>

With this commit, OVS will match the data in the RARP packets having
ethertype 0x8035, in the same way as the data in the ARP packets.

Signed-off-by: Mehak Mahajan <mmahajan@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 733cbf4..e6ce902 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -689,7 +689,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 			}
 		}
 
-	} else if (key->eth.type == htons(ETH_P_ARP) && arphdr_ok(skb)) {
+	} else if ((key->eth.type == htons(ETH_P_ARP) ||
+		   key->eth.type == htons(ETH_P_RARP)) && arphdr_ok(skb)) {
 		struct arp_eth_header *arp;
 
 		arp = (struct arp_eth_header *)skb_network_header(skb);
@@ -1086,7 +1087,8 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 			if (err)
 				return err;
 		}
-	} else if (swkey->eth.type == htons(ETH_P_ARP)) {
+	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
+		   swkey->eth.type == htons(ETH_P_RARP)) {
 		const struct ovs_key_arp *arp_key;
 
 		if (!(attrs & (1 << OVS_KEY_ATTR_ARP)))
@@ -1222,7 +1224,8 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 		ipv6_key->ipv6_tclass = swkey->ip.tos;
 		ipv6_key->ipv6_hlimit = swkey->ip.ttl;
 		ipv6_key->ipv6_frag = swkey->ip.frag;
-	} else if (swkey->eth.type == htons(ETH_P_ARP)) {
+	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
+		   swkey->eth.type == htons(ETH_P_RARP)) {
 		struct ovs_key_arp *arp_key;
 
 		nla = nla_reserve(skb, OVS_KEY_ATTR_ARP, sizeof(*arp_key));
-- 
1.7.9.5
