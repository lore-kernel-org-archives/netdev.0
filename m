From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] net: ping: Use right format specifier to avoid type casting
Date: Tue, 17 Jan 2017 10:21:19 +0800
Message-ID: <1484619679-17728-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg292.qq.com ([113.108.11.231]:45505 "EHLO smtpbg292.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750803AbdAQCc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 21:32:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The inet_num is u16, so use %hu instead of casting it to int. And
the sk_bound_dev_if is int actually, so it needn't cast to int.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/ping.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 86cca61..592db6a 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -433,9 +433,9 @@ int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	}
 
-	pr_debug("after bind(): num = %d, dif = %d\n",
-		 (int)isk->inet_num,
-		 (int)sk->sk_bound_dev_if);
+	pr_debug("after bind(): num = %hu, dif = %d\n",
+		 isk->inet_num,
+		 sk->sk_bound_dev_if);
 
 	err = 0;
 	if (sk->sk_family == AF_INET && isk->inet_rcv_saddr)
-- 
1.9.1
