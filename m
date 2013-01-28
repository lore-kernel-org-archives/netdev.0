From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Subject: [PATCH] [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in tcp_v4_conn_request() (updated)
Date: Sun, 27 Jan 2013 17:45:50 -0800
Message-ID: <1359337550-3958-1-git-send-email-niveditasinghvi@gmail.com>
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f169.google.com ([209.85.161.169]:40067 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756371Ab3A1Bvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 20:51:38 -0500
Received: by mail-gg0-f169.google.com with SMTP id j5so330005ggn.28
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2013 17:51:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nivedita Singhvi <niv@us.ibm.com>

We drop a connection request if the accept backlog is full and there are
sufficient packets in the syn queue to warrant starting drops. Increment the
appropriate counter so this isn't silent, for accurate stats and help in
debugging.

Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
---
 net/ipv4/tcp_ipv4.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bbbdcc5..49b4f50 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1502,8 +1502,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * clogging syn queue with openreqs with exponentially increasing
 	 * timeout.
 	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 		goto drop;
+	}
 
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
-- 
1.7.5.4
