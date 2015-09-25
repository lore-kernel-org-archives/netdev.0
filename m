From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/17] inet: constify ip_dont_fragment() arguments
Date: Fri, 25 Sep 2015 07:39:14 -0700
Message-ID: <1443191964-923-8-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36315 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932404AbbIYOkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:17 -0400
Received: by pablk4 with SMTP id lk4so10823337pab.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:07 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_dont_fragment() can accept const socket and dst

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 9b9ca2839399..525dc0778926 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -282,10 +282,12 @@ int ip_decrease_ttl(struct iphdr *iph)
 }
 
 static inline
-int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
+int ip_dont_fragment(const struct sock *sk, const struct dst_entry *dst)
 {
-	return  inet_sk(sk)->pmtudisc == IP_PMTUDISC_DO ||
-		(inet_sk(sk)->pmtudisc == IP_PMTUDISC_WANT &&
+	u8 pmtudisc = READ_ONCE(inet_sk(sk)->pmtudisc);
+
+	return  pmtudisc == IP_PMTUDISC_DO ||
+		(pmtudisc == IP_PMTUDISC_WANT &&
 		 !(dst_metric_locked(dst, RTAX_MTU)));
 }
 
-- 
2.6.0.rc2.230.g3dd15c0
