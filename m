From: Andreas Petlund <apetlund@simula.no>
Subject: [PATCH 1/3] net: TCP thin-stream detection
Date: Tue, 27 Oct 2009 17:31:49 +0100
Message-ID: <4AE72075.4070702@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:46928 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbZJ0Qb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 12:31:56 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N2oxl-0006Dr-2a
	for netdev@vger.kernel.org; Tue, 27 Oct 2009 17:32:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inline function to dynamically detect thin streams based on the number of packets in flight. Used to trigger thin-stream mechanisms.


Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 include/net/tcp.h |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..7c4482f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -800,6 +800,14 @@ static inline bool tcp_in_initial_slowstart(const struct tcp_sock *tp)
 	return tp->snd_ssthresh >= TCP_INFINITE_SSTHRESH;
 }
 
+/* Determines whether this is a thin stream (which may suffer from
+ * increased latency). Used to trigger latency-reducing mechanisms.
+ */
+static inline unsigned int tcp_stream_is_thin(const struct tcp_sock *tp)
+{
+	return tp->packets_out < 4;
+}
+
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
-- 
1.6.0.4


