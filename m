From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH ] net:dccp: do not report ICMP redirects to user space
Date: Wed, 18 Sep 2013 20:03:27 +0800
Message-ID: <5239968F.1070402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:39067 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752141Ab3IRME3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 08:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

DCCP shouldn't be setting sk_err on redirects as it
isn't an error condition. it should be doing exactly
what tcp is doing and leaving the error handler without
touching the socket.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/dccp/ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c61f9c..6cf9f77 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -135,6 +135,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		if (dst)
 			dst->ops->redirect(dst, sk, skb);
+		goto out;
 	}
 
 	if (type == ICMPV6_PKT_TOOBIG) {
-- 
1.8.3.1
