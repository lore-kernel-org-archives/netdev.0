From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] fix inverted test in __skb_recv_datagram
Date: Tue, 08 Dec 2015 14:47:56 +0000
Message-ID: <87h9jt809v.fsf@doppelsaurus.mobileactivedefense.com>
References: <20151206.233038.1580536748391971635.davem@davemloft.net>
	<874mft7sur.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151207.222827.1680789119862020474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207.222827.1680789119862020474.davem@davemloft.net> (David
	Miller's message of "Mon, 07 Dec 2015 22:28:27 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As the kernel generally uses negated error numbers, *err needs to be
compared with -EAGAIN (d'oh).

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Fixes: ea3793ee29d3 ("core: enable more fine-grained datagram reception control")
---
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 7daff66..fa9dc64 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -275,7 +275,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		if (skb)
 			return skb;
 
-		if (*err != EAGAIN)
+		if (*err != -EAGAIN)
 			break;
 	} while (timeo &&
 		!__skb_wait_for_more_packets(sk, err, &timeo, last));
