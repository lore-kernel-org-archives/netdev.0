From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH][IPV4] ip_gre: set mac_header correctly in receive path
Date: Wed, 19 Dec 2007 20:10:41 +0200
Message-ID: <47695EA1.10103@iki.fi>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi> <20071023202036.GA12066@ms2.inr.ac.ru> <471EDE22.4090408@iki.fi> <20071024100842.GA19369@ms2.inr.ac.ru> <4767D249.5050602@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:60429 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbXLSSK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 13:10:27 -0500
Received: by ug-out-1314.google.com with SMTP id z38so323137ugc.16
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 10:10:25 -0800 (PST)
In-Reply-To: <4767D249.5050602@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>

mac_header update in ipgre_recv() was incorrectly changed to
skb_reset_mac_header() when it was introduced.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
This replaces my earlier patch titled "ip_gre: use skb->{mac,
network}_header consistently". Apparently I hadn't done my homework how
to use *_header correctly. And I should have done a bit more testing to
figure out the previous patch does not work.

But the main problem was the receive path in the first place, and this
patch fixes it.

The bug was introduced in commit 459a98ed881802dee55897441bc7f77af614368e.
There might be other similar incorrect replaces.


 net/ipv4/ip_gre.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 02b02a8..4b93f32 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -613,7 +613,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 				offset += 4;
 		}
 
-		skb_reset_mac_header(skb);
+		skb->mac_header = skb->network_header;
 		__pskb_pull(skb, offset);
 		skb_reset_network_header(skb);
 		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
-- 
1.5.2.5
