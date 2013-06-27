From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: only apply anti-spoofing checks to not-pointopoint tunnels
Date: Thu, 27 Jun 2013 22:46:04 +0200
Message-ID: <20130627204604.GB8903@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: rm@romanrm.ru, davem@davemloft.net, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42255 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab3F0UqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 16:46:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because of commit 218774dc341f219bfcf940304a081b121a0e8099 ("ipv6: add
anti-spoofing checks for 6to4 and 6rd") the sit driver dropped packets
for 2002::/16 destinations and sources even when configured to work as a
tunnel with fixed endpoint. We may only apply the 6rd/6to4 anti-spoofing
checks if the device is not in pointopoint mode.

This was an oversight from me in the above commit, sorry.  Thanks to
Roman Mamedov for reporting this!

Reported-by: Roman Mamedov <rm@romanrm.ru>
Cc: David Miller <davem@davemloft.net>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
David, could you please (after review) put this in the stable queue for
a potential v3.9.9 release? It is only applicable for v3.9. Thanks!

 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3353634..60df36d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -589,7 +589,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 				tunnel->dev->stats.rx_errors++;
 				goto out;
 			}
-		} else {
+		} else if (!(tunnel->dev->flags&IFF_POINTOPOINT)) {
 			if (is_spoofed_6rd(tunnel, iph->saddr,
 					   &ipv6_hdr(skb)->saddr) ||
 			    is_spoofed_6rd(tunnel, iph->daddr,
-- 
1.8.1.4
