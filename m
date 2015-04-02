From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC PATCH 2/5] geneve: move definition of geneve_hdr() to geneve.h
Date: Thu,  2 Apr 2015 15:17:03 -0400
Message-ID: <1428002227-11636-3-git-send-email-linville@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49878 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbbDBTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 15:19:13 -0400
In-Reply-To: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a static inline with identical definitions in multiple places...

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 include/net/geneve.h           | 5 +++++
 net/ipv4/geneve.c              | 5 -----
 net/openvswitch/vport-geneve.c | 5 -----
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/net/geneve.h b/include/net/geneve.h
index 14fb8d3390b4..2a0543a1899d 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -62,6 +62,11 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
+static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
+{
+	return (struct genevehdr *)(udp_hdr(skb) + 1);
+}
+
 #ifdef CONFIG_INET
 struct geneve_sock;
 
diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index ba5283adbee8..7990075d3fc8 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -60,11 +60,6 @@ struct geneve_net {
 
 static int geneve_net_id;
 
-static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
-{
-	return (struct genevehdr *)(udp_hdr(skb) + 1);
-}
-
 static struct geneve_sock *geneve_find_sock(struct net *net,
 					    sa_family_t family, __be16 port)
 {
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index bf02fd5808c9..208c576bd1b6 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -46,11 +46,6 @@ static inline struct geneve_port *geneve_vport(const struct vport *vport)
 	return vport_priv(vport);
 }
 
-static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
-{
-	return (struct genevehdr *)(udp_hdr(skb) + 1);
-}
-
 /* Convert 64 bit tunnel ID to 24 bit VNI. */
 static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
 {
-- 
2.1.0
