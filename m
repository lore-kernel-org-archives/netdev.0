From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: |PATCH net-next-2.6] ifb: use netif_receive_skb() instead of
 netif_rx()
Date: Wed, 15 Dec 2010 09:39:58 +0100
Message-ID: <1292402398.3427.6.camel@edumazet-laptop>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
	 <1292397202.2377.13.camel@edumazet-laptop>
	 <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:52949 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab0LOIkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 03:40:03 -0500
Received: by fxm18 with SMTP id 18so1742231fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 00:40:02 -0800 (PST)
In-Reply-To: <AANLkTi=TuZNTXTBxmLqu0yyF=f0xM3CQyr_stRHerv6r@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ri_tasklet(), we run from softirq, so can directly handle packet
through netif_receive_skb() instead of netif_rx().
There is no risk of recursion.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ifb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index bfa03db..a44901b 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -96,7 +96,7 @@ static void ri_tasklet(unsigned long dev)
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
 			skb_pull(skb, skb->dev->hard_header_len);
-			netif_rx(skb);
+			netif_receive_skb(skb);
 		} else
 			BUG();
 	}


