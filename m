From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 1/3] ipv4: warn once on passing AF_INET6 socket to ip_recv_error
Date: Sun, 30 Nov 2014 22:22:33 -0500
Message-ID: <1417404155-28607-2-git-send-email-willemb@google.com>
References: <1417404155-28607-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, luto@amacapital.net, richardcochran@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:46710 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaLADWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2014 22:22:40 -0500
Received: by mail-yh0-f50.google.com with SMTP id 29so4788573yhl.23
        for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 19:22:40 -0800 (PST)
In-Reply-To: <1417404155-28607-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

One line change, in response to catching an occurrence of this bug.
See also fix f4713a3dfad0 ("net-timestamp: make tcp_recvmsg call ...")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_sockglue.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b782657..59eba6c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -414,6 +414,8 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	int err;
 	int copied;
 
+	WARN_ON_ONCE(sk->sk_family == AF_INET6);
+
 	err = -EAGAIN;
 	skb = sock_dequeue_err_skb(sk);
 	if (skb == NULL)
-- 
2.2.0.rc0.207.ga3a616c
