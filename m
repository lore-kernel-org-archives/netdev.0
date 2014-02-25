From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: tcp: use NET_INC_STATS()
Date: Tue, 25 Feb 2014 04:31:03 -0800
Message-ID: <1393331463.2316.139.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
	 <20140219.131708.562226572566677127.davem@davemloft.net>
	 <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140219185949.GA1179@order.stressinduktion.org>
	 <20140219191831.GA7119@breakpoint.cc>
	 <20140219193038.GC1179@order.stressinduktion.org>
	 <1392839209.18849.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:48413 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbaBYMbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 07:31:06 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so8009026pab.24
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 04:31:04 -0800 (PST)
In-Reply-To: <1392839209.18849.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES can only be incremented
in tcp_transmit_skb() from softirq (incoming message or timer
activation), it is better to use NET_INC_STATS() instead of
NET_INC_STATS_BH() as tcp_transmit_skb() can be called from process
context.

This will avoid copy/paste confusion when/if we want to add
other SNMP counters in tcp_transmit_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_output.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 09805817627b..d718482fd11c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -864,8 +864,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 		if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
 			     fclone->fclone == SKB_FCLONE_CLONE))
-			NET_INC_STATS_BH(sock_net(sk),
-					 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
+			NET_INC_STATS(sock_net(sk),
+				      LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
 
 		if (unlikely(skb_cloned(skb)))
 			skb = pskb_copy(skb, gfp_mask);
