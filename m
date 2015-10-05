From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/5] net: Rename FLOWI_FLAG_VRFSRC to FLOWI_FLAG_L3MDEV_SRC
Date: Mon,  5 Oct 2015 08:51:23 -0700
Message-ID: <1444060287-11024-2-git-send-email-dsa@cumulusnetworks.com>
References: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34558 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbJEPvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:51:36 -0400
Received: by padhy16 with SMTP id hy16so40308621pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:51:35 -0700 (PDT)
In-Reply-To: <1444060287-11024-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c   | 4 ++--
 include/net/flow.h  | 2 +-
 include/net/route.h | 2 +-
 net/ipv4/udp.c      | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 474396353e7f..4fd5af1acff0 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -208,7 +208,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 		.flowi4_oif = vrf_dev->ifindex,
 		.flowi4_iif = LOOPBACK_IFINDEX,
 		.flowi4_tos = RT_TOS(ip4h->tos),
-		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_VRFSRC |
+		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_L3MDEV_SRC |
 				FLOWI_FLAG_SKIP_NH_OIF,
 		.daddr = ip4h->daddr,
 	};
@@ -545,7 +545,7 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 {
 	struct rtable *rth = NULL;
 
-	if (!(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
+	if (!(fl4->flowi4_flags & FLOWI_FLAG_L3MDEV_SRC)) {
 		struct net_vrf *vrf = netdev_priv(dev);
 
 		rth = vrf->rth;
diff --git a/include/net/flow.h b/include/net/flow.h
index 9b85db85f13c..83969eebebf3 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -34,7 +34,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
-#define FLOWI_FLAG_VRFSRC		0x04
+#define FLOWI_FLAG_L3MDEV_SRC		0x04
 #define FLOWI_FLAG_SKIP_NH_OIF		0x08
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
diff --git a/include/net/route.h b/include/net/route.h
index d32cb76f5302..3e18d90b3f4e 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -267,7 +267,7 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
 	if (netif_index_is_l3_master(sock_net(sk), oif))
-		flow_flags |= FLOWI_FLAG_VRFSRC | FLOWI_FLAG_SKIP_NH_OIF;
+		flow_flags |= FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF;
 
 	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 156ba75b6000..b2882cfd3136 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1024,7 +1024,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		if (netif_index_is_l3_master(net, ipc.oif)) {
 			flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
 					   RT_SCOPE_UNIVERSE, sk->sk_protocol,
-					   (flow_flags | FLOWI_FLAG_VRFSRC |
+					   (flow_flags | FLOWI_FLAG_L3MDEV_SRC |
 					    FLOWI_FLAG_SKIP_NH_OIF),
 					   faddr, saddr, dport,
 					   inet->inet_sport);
-- 
1.9.1
