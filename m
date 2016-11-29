From: Manjeet Pawar <manjeet.p@samsung.com>
Subject: [PATCH] ipv6:ip6_xmit remove unnecessary np NULL check
Date: Tue, 29 Nov 2016 12:02:59 +0530
Message-ID: <1480401179-9220-1-git-send-email-manjeet.p@samsung.com>
Cc: pankaj.m@samsung.com, ajeet.y@samsung.com,
        Rohit Thapliyal <r.thapliyal@samsung.com>,
        Manjeet Pawar <manjeet.p@samsung.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:43592 "EHLO
        mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755878AbcK2GiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:38:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rohit Thapliyal <r.thapliyal@samsung.com>

np NULL check doesn't seem required here as it shall never
be NULL anyways in inet6_sk(sk).

Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>
Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
Signed-off-by: David Miller <davem@davemloft.net>
Reviewed-by: Akhilesh Kumar <akhilesh.k@samsung.com>

---
v2->v3: Modified as per the suggestion from David Miller
        ip6_xmit calls are made without checking NULL np
        pointer, so no need to explicitly check NULL np in
        ip6_xmit.

 include/linux/ipv6.h  | 2 +-
 net/ipv6/ip6_output.c | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index a064997..6c9c604 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -299,7 +299,7 @@ struct tcp6_timewait_sock {
 
 static inline struct ipv6_pinfo *inet6_sk(const struct sock *__sk)
 {
-	return sk_fullsock(__sk) ? inet_sk(__sk)->pinet6 : NULL;
+	return inet_sk(__sk)->pinet6;
 }
 
 static inline struct raw6_sock *raw6_sk(const struct sock *sk)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 59eb4ed..f8c63ec 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -213,8 +213,7 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	/*
 	 *	Fill in the IPv6 header
 	 */
-	if (np)
-		hlimit = np->hop_limit;
+	hlimit = np->hop_limit;
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
-- 
1.9.1
