From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Initialize on-stack cork more efficiently.
Date: Fri, 06 May 2011 15:26:23 -0700 (PDT)
Message-ID: <20110506.152623.232747437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753561Ab1EFW0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 18:26:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ip_setup_cork() explicitly initializes every member of
inet_cork except flags, addr, and opt.  So we can simply
set those three members to zero instead of using a
memset() via an empty struct assignment.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index eb0647a..5f5fe4f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1408,7 +1408,7 @@ struct sk_buff *ip_make_skb(struct sock *sk,
 			    struct ipcm_cookie *ipc, struct rtable **rtp,
 			    unsigned int flags)
 {
-	struct inet_cork cork = {};
+	struct inet_cork cork;
 	struct sk_buff_head queue;
 	int err;
 
@@ -1417,6 +1417,9 @@ struct sk_buff *ip_make_skb(struct sock *sk,
 
 	__skb_queue_head_init(&queue);
 
+	cork.flags = 0;
+	cork.addr = 0;
+	cork.opt = 0;
 	err = ip_setup_cork(sk, &cork, ipc, rtp);
 	if (err)
 		return ERR_PTR(err);
-- 
1.7.5.1

