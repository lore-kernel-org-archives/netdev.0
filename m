From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] fix inverted test in __skb_recv_datagram
Date: Mon, 07 Dec 2015 23:30:58 +0000
Message-ID: <87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <874mfv7055.fsf@doppelsaurus.mobileactivedefense.com>
	<20151206.233038.1580536748391971635.davem@davemloft.net>
	<874mft7sur.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rweikusat@mobileactivedefense.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:60729 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755719AbbLGXbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 18:31:09 -0500
In-Reply-To: <874mft7sur.fsf_-_@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Mon, 07 Dec 2015 23:15:56 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the kernel generally uses negated error numbers, *err needs to be
compared with -EAGAIN (d'oh).

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Fixes: ea3793ee29d3
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
