From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip_gre: remove an extra dst_release()
Date: Tue, 19 Feb 2013 14:14:10 -0800
Message-ID: <1361312050.19353.169.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:43463 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933538Ab3BSWOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:14:12 -0500
Received: by mail-da0-f52.google.com with SMTP id f10so3133238dak.11
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 14:14:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 68c331631143 (v4 GRE: Add TCP segmentation offload for GRE)
introduced a bug in error path.

dst is attached to skb, so will be released when skb is freed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ip_gre.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 31bc941..5ef4da7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1006,10 +1006,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 			if (skb_has_shared_frag(skb)) {
 				err = __skb_linearize(skb);
-				if (err) {
-					ip_rt_put(rt);
+				if (err)
 					goto tx_error;
-				}
 			}
 
 			*ptr = 0;
