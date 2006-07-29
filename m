From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 18/23] [PATCH] [XFRM] IPV6: Update outbound state timestamp for each sending.
Date: Sat, 29 Jul 2006 18:30:47 +0900
Message-ID: <11541654473727-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:29315 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161134AbWG2Jas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:48 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mobile IPv6 enabled nodes will want to know traffic status of each
binding (e.g. judgement to request binding refresh by correspondent node,
or to keep home/care-of nonce alive by mobile node).
The last used timestamp is an important hint about it.
Based on MIPL2 kernel patch.
---
 net/ipv6/xfrm6_output.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 8792b5c..9ff4230 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -130,6 +130,11 @@ static int xfrm6_output_one(struct sk_bu
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 
+#ifdef CONFIG_XFRM_ADVANCED
+		if (!xfrm_id_proto_match(x->id.proto, IPSEC_PROTO_ANY))
+			x->curlft.use_time = (unsigned long) xtime.tv_sec;
+#endif
+
 		spin_unlock_bh(&x->lock);
 
 		skb->nh.raw = skb->data;
-- 
1.4.1

