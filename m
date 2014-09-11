From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 7/8] ipv6: update the comment in mcast.c
Date: Thu, 11 Sep 2014 15:35:15 -0700
Message-ID: <1410474916-21873-8-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44274 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbaIKWfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:47 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so11161791pdj.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:46 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/mcast.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 4fb761d..d64e263 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -556,9 +556,8 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	}
 
 	err = -EADDRNOTAVAIL;
-	/*
-	 * changes to the ipv6_mc_list require the socket lock and
-	 * a read lock on ip6_sk_mc_lock. We have the socket lock,
+	/* changes to the ipv6_mc_list require the socket lock and
+	 * rtnl lock. We have the socket lock and rcu read lock,
 	 * so reading the list is safe.
 	 */
 
@@ -582,9 +581,8 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	    copy_to_user(optval, gsf, GROUP_FILTER_SIZE(0))) {
 		return -EFAULT;
 	}
-	/* changes to psl require the socket lock, a read lock on
-	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
-	 * have the socket lock, so reading here is safe.
+	/* changes to psl require the socket lock, and a write lock
+	 * on pmc->sflock. We have the socket lock so reading here is safe.
 	 */
 	for (i = 0; i < copycount; i++) {
 		struct sockaddr_in6 *psin6;
@@ -2350,7 +2348,7 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 {
 	int err;
 
-	/* callers have the socket lock and a write lock on ipv6_sk_mc_lock,
+	/* callers have the socket lock and rtnl lock
 	 * so no other readers or writers of iml or its sflist
 	 */
 	if (!iml->sflist) {
-- 
1.8.3.1
