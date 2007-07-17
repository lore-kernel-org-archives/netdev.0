From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] negative groups in netlink_setsockopt
Date: Tue, 17 Jul 2007 14:26:04 +0200
Message-ID: <1184675164.3773.83.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56182 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbXGQMej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 08:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reading netlink_setsockopt it's not immediately clear why there isn't a
bug when you pass in negative numbers, the reason being that the >=
comparison is really unsigned although 'val' is signed because
nlk->ngroups is unsigned. Make 'val' unsigned too.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 net/netlink/af_netlink.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- wireless-dev.orig/net/netlink/af_netlink.c	2007-07-17 14:05:14.580964463 +0200
+++ wireless-dev/net/netlink/af_netlink.c	2007-07-17 14:05:30.210964463 +0200
@@ -1012,7 +1012,8 @@ static int netlink_setsockopt(struct soc
 {
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	int val = 0, err;
+	unsigned int val = 0;
+	int err;
 
 	if (level != SOL_NETLINK)
 		return -ENOPROTOOPT;


