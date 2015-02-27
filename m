From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: cleanup static functions
Date: Thu, 26 Feb 2015 19:08:59 -0800
Message-ID: <1425006539.5565.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:45264 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbB0DJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 22:09:04 -0500
Received: by iecat20 with SMTP id at20so24921748iec.12
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 19:09:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_fastopen_create_child() is static and should not be exported.

tcp4_gso_segment() and tcp6_gso_segment() should be static.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_fastopen.c  |    1 -
 net/ipv4/tcp_offload.c   |    4 ++--
 net/ipv6/tcpv6_offload.c |    4 ++--
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index ea82fd492c1b..fe77417fc137 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -221,7 +221,6 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	WARN_ON(req->sk == NULL);
 	return true;
 }
-EXPORT_SYMBOL(tcp_fastopen_create_child);
 
 static bool tcp_fastopen_queue_check(struct sock *sk)
 {
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 9d7930ba8e0f..3f7c2fca5431 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -29,8 +29,8 @@ static void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq,
 	}
 }
 
-struct sk_buff *tcp4_gso_segment(struct sk_buff *skb,
-				 netdev_features_t features)
+static struct sk_buff *tcp4_gso_segment(struct sk_buff *skb,
+					netdev_features_t features)
 {
 	if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
 		return ERR_PTR(-EINVAL);
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index c1ab77105b4c..d883c9204c01 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -41,8 +41,8 @@ static int tcp6_gro_complete(struct sk_buff *skb, int thoff)
 	return tcp_gro_complete(skb);
 }
 
-struct sk_buff *tcp6_gso_segment(struct sk_buff *skb,
-				 netdev_features_t features)
+static struct sk_buff *tcp6_gso_segment(struct sk_buff *skb,
+					netdev_features_t features)
 {
 	struct tcphdr *th;
 
