From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/4] [IPV6] XFRM: Don't use old copy of pointer after
 pskb_may_pull().
Date: Wed, 19 Apr 2006 00:21:01 +0900 (JST)
Message-ID: <20060419.002101.65351047.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:2579 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932274AbWDRPSV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 11:18:21 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] XFRM: Don't use old copy of pointer after pskb_may_pull().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---

 net/ipv6/xfrm6_policy.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

83e25b9fb69b2c04ebfec2ee2b9fe95e5a7c0584
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 91cce8b..588922b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -193,7 +193,7 @@ _decode_session6(struct sk_buff *skb, st
 {
 	u16 offset = sizeof(struct ipv6hdr);
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
-	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+	struct ipv6_opt_hdr *exthdr;
 	u8 nexthdr = skb->nh.ipv6h->nexthdr;
 
 	memset(fl, 0, sizeof(struct flowi));
@@ -201,6 +201,8 @@ _decode_session6(struct sk_buff *skb, st
 	ipv6_addr_copy(&fl->fl6_src, &hdr->saddr);
 
 	while (pskb_may_pull(skb, skb->nh.raw + offset + 1 - skb->data)) {
+		exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+
 		switch (nexthdr) {
 		case NEXTHDR_ROUTING:
 		case NEXTHDR_HOP:
-- 
1.0.8
