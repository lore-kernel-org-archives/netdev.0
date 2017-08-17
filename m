From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next v2 1/2] tcp: Remove unnecessary dst check in tcp_conn_request.
Date: Wed, 16 Aug 2017 20:02:45 -0700
Message-ID: <1502938966-6345-2-git-send-email-xiangxia.m.yue@gmail.com>
References: <1502938966-6345-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:38378 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdHQDDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 23:03:10 -0400
Received: by mail-pg0-f68.google.com with SMTP id 123so7466717pga.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 20:03:10 -0700 (PDT)
In-Reply-To: <1502938966-6345-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because we remove the tcp_tw_recycle support in the commit
4396e46187c ('tcp: remove tcp_tw_recycle') and also delete
the code 'af_ops->route_req' for sysctl_tw_recycle in tcp_conn_request.
Now when we call the 'af_ops->route_req', the dist always is
NULL, and we remove the unnecessay check.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/ipv4/tcp_input.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d73903f..7eee2c7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6132,11 +6132,10 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 
 		isn = af_ops->init_seq(skb);
 	}
-	if (!dst) {
-		dst = af_ops->route_req(sk, &fl, req);
-		if (!dst)
-			goto drop_and_free;
-	}
+
+	dst = af_ops->route_req(sk, &fl, req);
+	if (!dst)
+		goto drop_and_free;
 
 	tcp_ecn_create_request(req, skb, sk, dst);
 
-- 
1.8.3.1
