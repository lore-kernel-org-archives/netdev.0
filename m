From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] tcp: allow segment with FIN in tcp_try_coalesce()
Date: Sun, 14 Sep 2014 19:56:19 -0700
Message-ID: <1410749780-30613-3-git-send-email-edumazet@google.com>
References: <1410749780-30613-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:48531 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332AbaIOC5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 22:57:06 -0400
Received: by mail-oa0-f74.google.com with SMTP id g18so287924oah.3
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 19:57:05 -0700 (PDT)
In-Reply-To: <1410749780-30613-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing special with allowing a segment with FIN to be aggregated,
if we take care to add tcp flags.

Signed-of-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8f639a4face9..228bf0c5ff19 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4143,9 +4143,6 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	*fragstolen = false;
 
-	if (tcp_hdr(from)->fin)
-		return false;
-
 	/* Its possible this segment overlaps with prior segment in queue */
 	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
 		return false;
@@ -4158,6 +4155,7 @@ static bool tcp_try_coalesce(struct sock *sk,
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
 	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
 	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
+	TCP_SKB_CB(to)->tcp_flags |= TCP_SKB_CB(from)->tcp_flags;
 	return true;
 }
 
-- 
2.1.0.rc2.206.gedb03e5
