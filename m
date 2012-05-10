From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/3] tcp: Schedule rmem for rcvq repair send
Date: Thu, 10 May 2012 15:50:01 +0400
Message-ID: <4FABAB69.70401@parallels.com>
References: <4FABAB39.6090201@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2657 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759191Ab2EJLuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 07:50:08 -0400
In-Reply-To: <4FABAB39.6090201@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted by Eric, no checks are performed on the data size we're
putting in the read queue during repair. Thus, validate the given
data size with the common rmem management routine.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7c6c99d..164659f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4769,6 +4769,9 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 	struct tcphdr *th;
 	bool fragstolen;
 
+	if (tcp_try_rmem_schedule(sk, size + sizeof(*th)))
+		goto err;
+
 	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
 	if (!skb)
 		goto err;
-- 
1.5.5.6
