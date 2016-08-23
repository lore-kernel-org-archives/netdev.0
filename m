From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] tipc: use kfree_skb() instead of kfree()
Date: Tue, 23 Aug 2016 23:01:02 +0000
Message-ID: <1471993262-4061-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34050 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752643AbcHWXCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:02:15 -0400
Received: by mail-pa0-f68.google.com with SMTP id hh10so10636620pac.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 16:01:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Use kfree_skb() instead of kfree() to free sk_buff.

Fixes: 0d051bf93c06 ("tipc: make bearer packet filtering generic")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/tipc/bearer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 6fc4e3c..28056fa 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -529,7 +529,7 @@ void tipc_bearer_xmit(struct net *net, u32 bearer_id,
 		if (likely(test_bit(0, &b->up) || msg_is_reset(buf_msg(skb))))
 			b->media->send_msg(net, skb, b, dst);
 		else
-			kfree(skb);
+			kfree_skb(skb);
 	}
 	rcu_read_unlock();
 }
