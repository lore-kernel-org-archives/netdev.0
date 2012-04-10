From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/2] l2tp: fix refcount leak in l2tp_ip sockets
Date: Tue, 10 Apr 2012 11:10:42 +0100
Message-ID: <1334052643-10910-2-git-send-email-jchapman@katalix.com>
References: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53106 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756080Ab2DJKLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 06:11:05 -0400
In-Reply-To: <1334052643-10910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The l2tp_ip socket close handler does not update the module refcount
correctly which prevents module unload after the first bind() call on
an L2TPv3 IP encapulation socket.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 55670ec..b56be14 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -232,7 +232,7 @@ static void l2tp_ip_close(struct sock *sk, long timeout)
 {
 	write_lock_bh(&l2tp_ip_lock);
 	hlist_del_init(&sk->sk_bind_node);
-	hlist_del_init(&sk->sk_node);
+	sk_del_node_init(sk);
 	write_unlock_bh(&l2tp_ip_lock);
 	sk_common_release(sk);
 }
-- 
1.7.0.4
