From: Satoru SATOH <satoru.satoh@gmail.com>
Subject: [PATCH 2/2] tcp: Fix tcp_prequeue() to get correct rto_min value
Date: Sat, 2 May 2009 16:51:33 +0900
Message-ID: <20090502075133.GC13165@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:6823 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbZEBH4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 03:56:36 -0400
Received: by rv-out-0506.google.com with SMTP id f6so503499rvb.5
        for <netdev@vger.kernel.org>; Sat, 02 May 2009 00:56:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch depends on the previous patch, makes tcp_prequeue() uses the
correct tcp rto_min value returns from tcp_rto_min().

Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

---
 include/net/tcp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 284cc68..a54d139 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -920,7 +920,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 			wake_up_interruptible(sk->sk_sleep);
 			if (!inet_csk_ack_scheduled(sk))
 				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						          (3 * TCP_RTO_MIN) / 4,
+						          (3 * tcp_rto_min(sk)) / 4,
 							  TCP_RTO_MAX);
 		}
 		return 1;
-- 
1.6.2.2

