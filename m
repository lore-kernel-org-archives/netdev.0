From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: avoid cwnd undo after receiving ECN
Date: Fri, 29 Jan 2016 15:11:50 -0800
Message-ID: <1454109110-32068-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34463 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbcA2XMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 18:12:22 -0500
Received: by mail-pa0-f48.google.com with SMTP id uo6so49219318pac.1
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 15:12:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4015 section 3.4 says the TCP sender MUST refrain from
reversing the congestion control state when the ACK signals
congestion through the ECN-Echo flag. Currently we may not
always do that when prior_ssthresh is reset upon receiving
ACKs with ECE marks. This patch fixes that.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d2ad433..1c2a734 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2366,8 +2366,6 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 			tp->snd_ssthresh = tp->prior_ssthresh;
 			tcp_ecn_withdraw_cwr(tp);
 		}
-	} else {
-		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
 	}
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	tp->undo_marker = 0;
-- 
2.7.0.rc3.207.g0ac5344
