From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v3 1/3] net: TCP thin-stream detection
Date: Thu, 11 Feb 2010 13:07:16 +0100
Message-ID: <4B73F2F4.8090901@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:47256 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab0BKMHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 07:07:14 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1NfXpB-0006Oj-4F
	for netdev@vger.kernel.org; Thu, 11 Feb 2010 13:07:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No changes here from v2.


Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 include/net/tcp.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 87d164b..e5e2056 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1386,6 +1386,13 @@ static inline void tcp_highest_sack_combine(struct sock *sk,
 		tcp_sk(sk)->highest_sack = new;
 }
 
+/* Determines whether this is a thin stream (which may suffer from
+ * increased latency). Used to trigger latency-reducing mechanisms.*/
+static inline unsigned int tcp_stream_is_thin(struct tcp_sock *tp)
+{
+	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
-- 
1.6.3.3

