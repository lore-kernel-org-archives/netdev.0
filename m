From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] tcp: bound RTO to minimum
Date: Thu, 25 Aug 2011 01:41:50 +0200
Message-ID: <1314229310-8074-1-git-send-email-hagen@jauu.net>
References: <1314226834.6797.5.camel@edumazet-laptop>
Cc: eric.dumazet@gmail.com, Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:54470 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751054Ab1HXXl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 19:41:57 -0400
In-Reply-To: <1314226834.6797.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if calculated RTO is less then TCP_RTO_MIN. If this is true we
adjust the value to TCP_RTO_MIN.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/net/tcp.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 149a415..9b5f4bf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -520,6 +520,8 @@ static inline void tcp_bound_rto(const struct sock *sk)
 {
 	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
 		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
+	else if (inet_csk(sk)->icsk_rto < TCP_RTO_MIN)
+		inet_csk(sk)->icsk_rto = TCP_RTO_MIN;
 }
 
 static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
-- 
1.7.4.1.57.g0466.dirty
