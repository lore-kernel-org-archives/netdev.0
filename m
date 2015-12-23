From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net] sctp: label accepted/peeled off sockets
Date: Wed, 23 Dec 2015 16:44:09 -0200
Message-ID: <339eee4a8d20118f871fda8a8b38591a60bea59b.1450895942.git.marcelo.leitner@gmail.com>
Cc: cluster-devel@redhat.com, pmoore@redhat.com, teigland@redhat.com,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933310AbbLWSoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 13:44:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Accepted or peeled off sockets were missing a security label (e.g.
SELinux) which means that socket was in "unlabeled" state.

This patch clones the sock's label from the parent sock and resolves the
issue (similar to AF_BLUETOOTH protocol family).

Cc: Paul Moore <pmoore@redhat.com>
Cc: David Teigland <teigland@redhat.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 400a14d744834c7a503b338bc68f5f8b5b5dae8e..b67162767b7957b3e9f4f7bf52ab51fc1a3499c8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -7202,6 +7202,8 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 
 	if (newsk->sk_flags & SK_FLAGS_TIMESTAMP)
 		net_enable_timestamp();
+
+	security_sk_clone(sk, newsk);
 }
 
 static inline void sctp_copy_descendant(struct sock *sk_to,
-- 
2.5.0
