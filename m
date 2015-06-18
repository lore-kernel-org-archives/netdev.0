From: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>
Subject: [PATCH net-next] inet_diag: Remove _bh suffix in inet_diag_dump_reqs().
Date: Thu, 18 Jun 2015 20:40:54 +0900
Message-ID: <1434627654-3630-1-git-send-email-shimoda.hiroaki@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35562 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754252AbbFRLlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 07:41:06 -0400
Received: by pacyx8 with SMTP id yx8so59781503pac.2
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 04:41:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_diag_dump_reqs() is called from inet_diag_dump_icsk() with BH
disabled. So no need to disable BH in inet_diag_dump_reqs().

Signed-off-by: Hiroaki Shimoda <shimoda.hiroaki@gmail.com>
---
 net/ipv4/inet_diag.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 21985d8d41e7..4ca789ba63cb 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -746,7 +746,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 
 	entry.family = sk->sk_family;
 
-	spin_lock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_lock(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	lopt = icsk->icsk_accept_queue.listen_opt;
 	if (!lopt || !listen_sock_qlen(lopt))
@@ -794,7 +794,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 	}
 
 out:
-	spin_unlock_bh(&icsk->icsk_accept_queue.syn_wait_lock);
+	spin_unlock(&icsk->icsk_accept_queue.syn_wait_lock);
 
 	return err;
 }
-- 
2.3.6
