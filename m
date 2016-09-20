From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v4 net-next 01/16] tcp: cdg: rename struct minmax in tcp_cdg.c to avoid a naming conflict
Date: Mon, 19 Sep 2016 23:39:08 -0400
Message-ID: <1474342763-16715-2-git-send-email-ncardwell@google.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34286 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753214AbcITDja (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 23:39:30 -0400
Received: by mail-qk0-f171.google.com with SMTP id n185so4361140qke.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 20:39:29 -0700 (PDT)
In-Reply-To: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

The upcoming change "lib/win_minmax: windowed min or max estimator"
introduces a struct called minmax, which is then included in
include/linux/tcp.h in the upcoming change "tcp: use windowed min
filter library for TCP min_rtt estimation". This would create a
compilation error for tcp_cdg.c, which defines its own minmax
struct. To avoid this naming conflict (and potentially others in the
future), this commit renames the version used in tcp_cdg.c to
cdg_minmax.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/ipv4/tcp_cdg.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index 03725b2..35b2803 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -56,7 +56,7 @@ MODULE_PARM_DESC(use_shadow, "use shadow window heuristic");
 module_param(use_tolerance, bool, 0644);
 MODULE_PARM_DESC(use_tolerance, "use loss tolerance heuristic");
 
-struct minmax {
+struct cdg_minmax {
 	union {
 		struct {
 			s32 min;
@@ -74,10 +74,10 @@ enum cdg_state {
 };
 
 struct cdg {
-	struct minmax rtt;
-	struct minmax rtt_prev;
-	struct minmax *gradients;
-	struct minmax gsum;
+	struct cdg_minmax rtt;
+	struct cdg_minmax rtt_prev;
+	struct cdg_minmax *gradients;
+	struct cdg_minmax gsum;
 	bool gfilled;
 	u8  tail;
 	u8  state;
@@ -353,7 +353,7 @@ static void tcp_cdg_cwnd_event(struct sock *sk, const enum tcp_ca_event ev)
 {
 	struct cdg *ca = inet_csk_ca(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct minmax *gradients;
+	struct cdg_minmax *gradients;
 
 	switch (ev) {
 	case CA_EVENT_CWND_RESTART:
-- 
2.8.0.rc3.226.g39d4020
