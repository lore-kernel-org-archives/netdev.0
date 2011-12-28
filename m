From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/5] tcp_diag: Don't report max ack backlog in wqueue
Date: Wed, 28 Dec 2011 17:36:28 +0400
Message-ID: <4EFB1B5C.2070005@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18463 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753751Ab1L1Ngg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:36:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not correct and actually makes ss work differently on proc
vs netlink -- in the former case 0 is reported.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/tcp_diag.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 8cd357a..3f2e2ef 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -25,7 +25,7 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 
 	if (sk->sk_state == TCP_LISTEN) {
 		r->idiag_rqueue = sk->sk_ack_backlog;
-		r->idiag_wqueue = sk->sk_max_ack_backlog;
+		r->idiag_wqueue = 0;
 	} else {
 		r->idiag_rqueue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
 		r->idiag_wqueue = tp->write_seq - tp->snd_una;
-- 
1.5.5.6
