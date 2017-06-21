From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next] idsn: fix wrong skb_put() used
Date: Wed, 21 Jun 2017 20:04:40 +0800
Message-ID: <1498046680-22872-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:55627 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751434AbdFUMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 08:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

in my commit b952f4dff2751252db073c27c0f8a16a416a2ddc,
-	*(u8 *)skb_put(skb_out, 1) = (u8)(accm >> 24);	\
+	skb_put(skb_out, (u8)(accm >> 24));	\
it should skb_put_u8()

Fixes: b952f4dff275 ("net: manual clean code which call skb_put_[data:zero])")
Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/isdn/i4l/isdn_bsdcomp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/i4l/isdn_bsdcomp.c b/drivers/isdn/i4l/isdn_bsdcomp.c
index 5b64a13..99012c0 100644
--- a/drivers/isdn/i4l/isdn_bsdcomp.c
+++ b/drivers/isdn/i4l/isdn_bsdcomp.c
@@ -472,7 +472,7 @@ static int bsd_compress(void *state, struct sk_buff *skb_in, struct sk_buff *skb
 		accm |= ((ent) << bitno);				\
 		do	{						\
 			if (skb_out && skb_tailroom(skb_out) > 0)	\
-				skb_put(skb_out, (u8)(accm >> 24));	\
+				skb_put_u8(skb_out, (u8)(accm >> 24));	\
 			accm <<= 8;					\
 			bitno += 8;					\
 		} while (bitno <= 24);					\
-- 
2.7.4
