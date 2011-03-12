From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/25] ipv4: Use flowi4 in UDP
Date: Sat, 12 Mar 2011 15:28:56 -0800 (PST)
Message-ID: <20110312.152856.35042576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756176Ab1CLX2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:28:18 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A996724C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:28:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/udp.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 25c0807..91cba3c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -770,7 +770,7 @@ static int udp_push_pending_frames(struct sock *sk)
 {
 	struct udp_sock  *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	struct flowi *fl = &inet->cork.fl;
+	struct flowi4 *fl4 = &inet->cork.fl.u.ip4;
 	struct sk_buff *skb;
 	int err = 0;
 
@@ -778,7 +778,7 @@ static int udp_push_pending_frames(struct sock *sk)
 	if (!skb)
 		goto out;
 
-	err = udp_send_skb(skb, fl->fl4_dst, fl->fl4_dport);
+	err = udp_send_skb(skb, fl4->daddr, fl4->uli.ports.dport);
 
 out:
 	up->len = 0;
@@ -791,6 +791,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct udp_sock *up = udp_sk(sk);
+	struct flowi4 *fl4;
 	int ulen = len;
 	struct ipcm_cookie ipc;
 	struct rtable *rt = NULL;
@@ -972,10 +973,11 @@ back_from_confirm:
 	/*
 	 *	Now cork the socket to pend data.
 	 */
-	inet->cork.fl.fl4_dst = daddr;
-	inet->cork.fl.fl4_dport = dport;
-	inet->cork.fl.fl4_src = saddr;
-	inet->cork.fl.fl4_sport = inet->inet_sport;
+	fl4 = &inet->cork.fl.u.ip4;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+	fl4->uli.ports.dport = dport;
+	fl4->uli.ports.sport = inet->inet_sport;
 	up->pending = AF_INET;
 
 do_append_data:
-- 
1.7.4.1

