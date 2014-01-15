From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not export tcp_gso_segment() and
 tcp_gro_receive()
Date: Tue, 14 Jan 2014 16:31:46 -0800
Message-ID: <1389745906.31367.294.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f169.google.com ([209.85.161.169]:43301 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbaAOAbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:31:50 -0500
Received: by mail-gg0-f169.google.com with SMTP id j5so314893ggn.14
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 16:31:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_gso_segment() and tcp_gro_receive() no longer need to be
exported. IPv4 and IPv6 offloads are statically linked.

Note that tcp_gro_complete() is still used by bnx2x, unfortunately.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_offload.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 771a3950d87a..b92b81718ca4 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -138,7 +138,6 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 out:
 	return segs;
 }
-EXPORT_SYMBOL(tcp_gso_segment);
 
 struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
@@ -235,7 +234,6 @@ out:
 
 	return pp;
 }
-EXPORT_SYMBOL(tcp_gro_receive);
 
 int tcp_gro_complete(struct sk_buff *skb)
 {
