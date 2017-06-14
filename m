From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 11/11] qrtr: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:59:25 +0800
Message-ID: <1497452365-5177-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:33244 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751857AbdFNO7z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:59:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/qrtr/qrtr.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index c7a5d86..e96353d 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -285,8 +285,7 @@ static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
 	if (!skb)
 		return NULL;
 
-	buf = (__le32 *)skb_put(skb, pkt_len);
-	memset(buf, 0, pkt_len);
+	buf = (__le32 *)skb_put_zero(skb, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_RESUME_TX);
 	buf[1] = cpu_to_le32(src_node);
 	buf[2] = cpu_to_le32(port);
@@ -306,8 +305,7 @@ static struct sk_buff *qrtr_alloc_local_bye(u32 src_node)
 	if (!skb)
 		return NULL;
 
-	buf = (__le32 *)skb_put(skb, pkt_len);
-	memset(buf, 0, pkt_len);
+	buf = (__le32 *)skb_put_zero(skb, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_BYE);
 
 	return skb;
@@ -324,8 +322,7 @@ static struct sk_buff *qrtr_alloc_del_client(struct sockaddr_qrtr *sq)
 	if (!skb)
 		return NULL;
 
-	buf = (__le32 *)skb_put(skb, pkt_len);
-	memset(buf, 0, pkt_len);
+	buf = (__le32 *)skb_put_zero(skb, pkt_len);
 	buf[0] = cpu_to_le32(QRTR_TYPE_DEL_CLIENT);
 	buf[1] = cpu_to_le32(sq->sq_node);
 	buf[2] = cpu_to_le32(sq->sq_port);
-- 
2.7.4
