From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] af_key: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:31:04 +0800
Message-ID: <49A51DE8.406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64191 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1762611AbZBYKbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:31:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/key/af_key.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7dcbde3..643c1be 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -313,8 +313,7 @@ static int pfkey_broadcast(struct sk_buff *skb, gfp_t allocation,
 	if (one_sk != NULL)
 		err = pfkey_broadcast_one(skb, &skb2, allocation, one_sk);
 
-	if (skb2)
-		kfree_skb(skb2);
+	kfree_skb(skb2);
 	kfree_skb(skb);
 	return err;
 }
@@ -3573,8 +3572,7 @@ static int pfkey_sendmsg(struct kiocb *kiocb,
 out:
 	if (err && hdr && pfkey_error(hdr, err, sk) == 0)
 		err = 0;
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 
 	return err ? : len;
 }
-- 
1.5.3.8




