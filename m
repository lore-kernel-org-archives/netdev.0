From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 1/2] tcp: Fix out of bounds access to tcpm_vals
Date: Wed, 11 Jul 2012 17:18:04 -0700
Message-ID: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.duyck@gmail.com,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17193 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933503Ab2GLARo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 20:17:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent patch "tcp: Maintain dynamic metrics in local cache." introduced
an out of bounds access due to what appears to be a typo.   I believe this
change should resolve the issue by replacing the access to RTAX_CWND with
TCP_METRIC_CWND.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/ipv4/tcp_metrics.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 1fd83d3..5a38a2d 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -412,7 +412,7 @@ void tcp_update_metrics(struct sock *sk)
 				       max(tp->snd_cwnd >> 1, tp->snd_ssthresh));
 		if (!tcp_metric_locked(tm, TCP_METRIC_CWND)) {
 			val = tcp_metric_get(tm, TCP_METRIC_CWND);
-			tcp_metric_set(tm, RTAX_CWND, (val + tp->snd_cwnd) >> 1);
+			tcp_metric_set(tm, TCP_METRIC_CWND, (val + tp->snd_cwnd) >> 1);
 		}
 	} else {
 		/* Else slow start did not finish, cwnd is non-sense,
