From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] atm: unset IFF_XMIT_DST_RELEASE in clip_setup()
Date: Thu, 28 May 2009 23:14:49 +0200
Message-ID: <4A1EFEC9.3050905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50975 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980AbZE1VOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 17:14:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clip_start_xmit() needs skb->dst so tell dev_hard_start_xmit()
to no release it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 3dc0a3a..99b6052 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -568,6 +568,7 @@ static void clip_setup(struct net_device *dev)
 	/* without any more elaborate queuing. 100 is a reasonable */
 	/* compromise between decent burst-tolerance and protection */
 	/* against memory hogs. */
+	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 }
 
 static int clip_create(int number)
