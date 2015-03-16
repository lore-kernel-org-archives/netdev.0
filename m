From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/5] inet: ip early demux should avoid request sockets
Date: Sun, 15 Mar 2015 21:12:13 -0700
Message-ID: <1426479136-15645-3-git-send-email-edumazet@google.com>
References: <1426479136-15645-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:34323 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbbCPEMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:12:30 -0400
Received: by obcwp18 with SMTP id wp18so9514766obc.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:12:30 -0700 (PDT)
In-Reply-To: <1426479136-15645-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a request socket is created, we do not cache ip route
dst entry, like for timewait sockets.

Let's use sk_fullsock() helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 2 +-
 net/ipv6/tcp_ipv6.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1f514a0c5e60..80067d5858b4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1518,7 +1518,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
-		if (sk->sk_state != TCP_TIME_WAIT) {
+		if (sk_fullsock(sk)) {
 			struct dst_entry *dst = sk->sk_rx_dst;
 
 			if (dst)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d89f028dc8c4..e4761b22307b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1583,7 +1583,7 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
 	if (sk) {
 		skb->sk = sk;
 		skb->destructor = sock_edemux;
-		if (sk->sk_state != TCP_TIME_WAIT) {
+		if (sk_fullsock(sk)) {
 			struct dst_entry *dst = sk->sk_rx_dst;
 
 			if (dst)
-- 
2.2.0.rc0.207.ga3a616c
