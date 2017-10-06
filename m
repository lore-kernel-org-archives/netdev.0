From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/7] tcp: reduce tcp_fastretrans_alert() verbosity
Date: Thu,  5 Oct 2017 22:21:25 -0700
Message-ID: <20171006052127.19913-6-edumazet@google.com>
References: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:49684 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751823AbdJFFVp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:45 -0400
Received: by mail-pf0-f177.google.com with SMTP id l188so9047381pfc.6
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:45 -0700 (PDT)
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With upcoming rb-tree implementation, the checks will trigger
more often, and this is expected.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index abc3b1db81f85a7feebda40cebc90c07afcef446..be7644204cd4493d0574aa065afbd6cb82a6b3bb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2804,9 +2804,9 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 	bool do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
 
-	if (WARN_ON(!tp->packets_out && tp->sacked_out))
+	if (!tp->packets_out && tp->sacked_out)
 		tp->sacked_out = 0;
-	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
+	if (!tp->sacked_out && tp->fackets_out)
 		tp->fackets_out = 0;
 
 	/* Now state machine starts.
-- 
2.14.2.920.gcf0c67979c-goog
