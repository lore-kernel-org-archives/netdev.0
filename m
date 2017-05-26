From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next] net: ndisc.c: reduce size of __ndisc_fill_addr_option()
Date: Sat, 27 May 2017 06:00:52 +0800
Message-ID: <1495836052-8377-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>, David Ahern <dsahern@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:54480 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1948772AbdEZWBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 18:01:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/ipv6/ndisc.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d310dc4..414e929 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -148,17 +148,18 @@ void __ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data,
 
 	opt[0] = type;
 	opt[1] = space>>3;
+	opt   += 2;
+	space -= 2;
 
-	memset(opt + 2, 0, pad);
+	memset(opt, 0, pad);
 	opt   += pad;
 	space -= pad;
 
-	memcpy(opt+2, data, data_len);
-	data_len += 2;
+	memcpy(opt, data, data_len);
 	opt += data_len;
 	space -= data_len;
-	if (space > 0)
-		memset(opt, 0, space);
+
+	memset(opt, 0, space);
 }
 EXPORT_SYMBOL_GPL(__ndisc_fill_addr_option);
 
-- 
2.7.4
