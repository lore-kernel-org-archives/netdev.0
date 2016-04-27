From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/17] net: rename ICMP6_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:36 -0700
Message-ID: <1461800683-25034-11-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36236 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbcD0XpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:17 -0400
Received: by mail-pf0-f170.google.com with SMTP id c189so26358609pfb.3
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:15 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename ICMP6_INC_STATS_BH() to __ICMP6_INC_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h  |  2 +-
 net/dccp/ipv6.c     |  8 ++++----
 net/ipv6/icmp.c     | 10 +++++-----
 net/ipv6/tcp_ipv6.c |  4 ++--
 net/ipv6/udp.c      |  4 ++--
 net/sctp/ipv6.c     |  2 +-
 6 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e93e947d04ff..a620fc56e2f5 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -179,7 +179,7 @@ extern int sysctl_mld_qrv;
 		_DEVUPD(net, ipv6, 64_BH, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINCATOMIC(net, icmpv6, , idev, field)
-#define ICMP6_INC_STATS_BH(net, idev, field)	\
+#define __ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINCATOMIC(net, icmpv6, _BH, idev, field)
 
 #define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index e175b8fe1a87..323c6b595e31 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -80,8 +80,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (skb->len < offset + sizeof(*dh) ||
 	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
-		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
-				   ICMP6_MIB_INERRORS);
+		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
+				  ICMP6_MIB_INERRORS);
 		return;
 	}
 
@@ -91,8 +91,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 					inet6_iif(skb));
 
 	if (!sk) {
-		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
-				   ICMP6_MIB_INERRORS);
+		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
+				  ICMP6_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 6b573ebe49de..823a1fc576e3 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -622,7 +622,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 				np->dontfrag, &sockc_unused);
 
 	if (err) {
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
+		__ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
 	} else {
 		err = icmpv6_push_pending_frames(sk, &fl6, &tmp_hdr,
@@ -674,7 +674,7 @@ void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
 	return;
 
 out:
-	ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
+	__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev), ICMP6_MIB_INERRORS);
 }
 
 /*
@@ -710,7 +710,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		skb_set_network_header(skb, nh);
 	}
 
-	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_INMSGS);
+	__ICMP6_INC_STATS(dev_net(dev), idev, ICMP6_MIB_INMSGS);
 
 	saddr = &ipv6_hdr(skb)->saddr;
 	daddr = &ipv6_hdr(skb)->daddr;
@@ -812,9 +812,9 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	return 0;
 
 csum_error:
-	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_CSUMERRORS);
+	__ICMP6_INC_STATS(dev_net(dev), idev, ICMP6_MIB_CSUMERRORS);
 discard_it:
-	ICMP6_INC_STATS_BH(dev_net(dev), idev, ICMP6_MIB_INERRORS);
+	__ICMP6_INC_STATS(dev_net(dev), idev, ICMP6_MIB_INERRORS);
 drop_no_count:
 	kfree_skb(skb);
 	return 0;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 52ca8fac7429..78c45c027acc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -336,8 +336,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 					skb->dev->ifindex);
 
 	if (!sk) {
-		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
-				   ICMP6_MIB_INERRORS);
+		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
+				  ICMP6_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1243d22e2b1d..1ba5a74ac18f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -521,8 +521,8 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	sk = __udp6_lib_lookup(net, daddr, uh->dest, saddr, uh->source,
 			       inet6_iif(skb), udptable, skb);
 	if (!sk) {
-		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
-				   ICMP6_MIB_INERRORS);
+		__ICMP6_INC_STATS(net, __in6_dev_get(skb->dev),
+				  ICMP6_MIB_INERRORS);
 		return;
 	}
 
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index ce46f1c7f133..0657d18a85bf 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -162,7 +162,7 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	skb->network_header   = saveip;
 	skb->transport_header = savesctp;
 	if (!sk) {
-		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_INERRORS);
+		__ICMP6_INC_STATS(net, idev, ICMP6_MIB_INERRORS);
 		goto out;
 	}
 
-- 
2.8.0.rc3.226.g39d4020
