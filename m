From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pktgen: remove one sparse error
Date: Mon, 25 May 2015 16:06:37 -0700
Message-ID: <1432595197.4060.201.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36564 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbEYXGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 19:06:39 -0400
Received: by igbpi8 with SMTP id pi8so44999775igb.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 16:06:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

net/core/pktgen.c:2672:43: warning: incorrect type in assignment (different base types)
net/core/pktgen.c:2672:43:    expected unsigned short [unsigned] [short] [usertype] <noident>
net/core/pktgen.c:2672:43:    got restricted __be16 [usertype] protocol

Let's use proper struct ethhdr instead of hard coding everything.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/pktgen.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 62f979984a23236db1109bb109f46a932840633f..46dfcfcb9c540dac0853b5648cce2d69e8fa3608 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2645,9 +2645,9 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
 		struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
 		int nhead = 0;
 		if (x) {
-			int ret;
-			__u8 *eth;
+			struct ethhdr *eth;
 			struct iphdr *iph;
+			int ret;
 
 			nhead = x->props.header_len - skb_headroom(skb);
 			if (nhead > 0) {
@@ -2667,9 +2667,9 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
 				goto err;
 			}
 			/* restore ll */
-			eth = (__u8 *) skb_push(skb, ETH_HLEN);
-			memcpy(eth, pkt_dev->hh, 12);
-			*(u16 *) &eth[12] = protocol;
+			eth = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+			memcpy(eth, pkt_dev->hh, 2 * ETH_ALEN);
+			eth->h_proto = protocol;
 
 			/* Update IPv4 header len as well as checksum value */
 			iph = ip_hdr(skb);
