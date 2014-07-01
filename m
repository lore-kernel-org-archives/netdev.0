From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] netlink: Fix do_one_broadcast() prototype.
Date: Tue,  1 Jul 2014 21:17:35 +0300
Message-ID: <1404238655-9762-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36816 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962AbaGASRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 14:17:52 -0400
Received: by mail-wg0-f47.google.com with SMTP id k14so10190495wgh.30
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 11:17:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the prototype of the do_one_broadcast() method so that it will return void.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/netlink/af_netlink.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 15c731f..e8c9f97 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1961,25 +1961,25 @@ struct netlink_broadcast_data {
 	void *tx_data;
 };
 
-static int do_one_broadcast(struct sock *sk,
-				   struct netlink_broadcast_data *p)
+static void do_one_broadcast(struct sock *sk,
+				    struct netlink_broadcast_data *p)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 	int val;
 
 	if (p->exclude_sk == sk)
-		goto out;
+		return;
 
 	if (nlk->portid == p->portid || p->group - 1 >= nlk->ngroups ||
 	    !test_bit(p->group - 1, nlk->groups))
-		goto out;
+		return;
 
 	if (!net_eq(sock_net(sk), p->net))
-		goto out;
+		return;
 
 	if (p->failure) {
 		netlink_overrun(sk);
-		goto out;
+		return;
 	}
 
 	sock_hold(sk);
@@ -2017,9 +2017,6 @@ static int do_one_broadcast(struct sock *sk,
 		p->skb2 = NULL;
 	}
 	sock_put(sk);
-
-out:
-	return 0;
 }
 
 int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid,
-- 
1.9.0
