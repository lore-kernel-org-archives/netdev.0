From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv4: remove the unnecessary variable in udp_mcast_next
Date: Fri, 11 Jul 2014 14:32:17 +0800
Message-ID: <1405060337-12528-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34944 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbaGKGcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 02:32:22 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so897624pab.22
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 23:32:22 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id ni6sm1629831pdb.96.2014.07.10.23.32.20
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 23:32:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/udp.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d92f94b..ac30e10 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -600,19 +600,18 @@ static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
 					     int dif)
 {
 	struct hlist_nulls_node *node;
-	struct sock *s = sk;
 	unsigned short hnum = ntohs(loc_port);
 
-	sk_nulls_for_each_from(s, node) {
-		if (__udp_is_mcast_sock(net, s,
+	sk_nulls_for_each_from(sk, node) {
+		if (__udp_is_mcast_sock(net, sk,
 					loc_port, loc_addr,
 					rmt_port, rmt_addr,
 					dif, hnum))
 			goto found;
 	}
-	s = NULL;
+	sk = NULL;
 found:
-	return s;
+	return sk;
 }
 
 /*
-- 
1.7.10.4
