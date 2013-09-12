From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 10/11] ipv6: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:51:49 +0800
Message-ID: <52319CC5.10902@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:28575 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754155Ab3ILKwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:52:44 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

And when dealing with redirect message, the err shoud
be assigned to 0.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/raw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 58916bb..6138199 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -336,7 +336,7 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
 	}
 	if (type == NDISC_REDIRECT)
-		ip6_sk_redirect(skb, sk);
+		err = 0;
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
-- 
1.8.3.1
