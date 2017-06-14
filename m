From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 01/11] ipv6: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:37:06 +0800
Message-ID: <1497451026-3923-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:57984 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750770AbdFNOhn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:37:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv6/mcast.c |  3 +--
 net/ipv6/ndisc.c | 13 ++-----------
 2 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 07403fa..b186c67 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2008,8 +2008,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
-	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct mld_msg));
-	memset(hdr, 0, sizeof(struct mld_msg));
+	hdr = (struct mld_msg *) skb_put_zero(skb, sizeof(struct mld_msg));
 	hdr->mld_type = type;
 	hdr->mld_mca = *addr;
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d310dc4..e6586ed 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -144,21 +144,12 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
 			      int data_len, int pad)
 {
 	int space = __ndisc_opt_addr_space(data_len, pad);
-	u8 *opt = skb_put(skb, space);
+	u8 *opt = skb_put_zero(skb, space);
 
 	opt[0] = type;
 	opt[1] = space>>3;
 
-	memset(opt + 2, 0, pad);
-	opt   += pad;
-	space -= pad;
-
-	memcpy(opt+2, data, data_len);
-	data_len += 2;
-	opt += data_len;
-	space -= data_len;
-	if (space > 0)
-		memset(opt, 0, space);
+	memcpy(opt+2+pad, data, data_len);
 }
 EXPORT_SYMBOL_GPL(__ndisc_fill_addr_option);
 
-- 
2.7.4
