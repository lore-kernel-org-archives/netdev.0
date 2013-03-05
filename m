From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: ipv4: Remove redundant NULL check
Date: Tue,  5 Mar 2013 16:57:09 +0530
Message-ID: <1362482829-10455-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:53450 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830Ab3CELhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 06:37:40 -0500
Received: by mail-pb0-f47.google.com with SMTP id rp2so4312199pbb.6
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 03:37:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on a null pointer is a NO-OP. Hence null check is not necessary.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
Compile tested on linux-next tree (20130305).
---
 net/ipv4/tcp.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 47e854f..3aa5d54 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -992,10 +992,8 @@ static inline int select_size(const struct sock *sk, bool sg)
 
 void tcp_free_fastopen_req(struct tcp_sock *tp)
 {
-	if (tp->fastopen_req != NULL) {
-		kfree(tp->fastopen_req);
-		tp->fastopen_req = NULL;
-	}
+	kfree(tp->fastopen_req);
+	tp->fastopen_req = NULL;
 }
 
 static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg, int *size)
-- 
1.7.4.1
