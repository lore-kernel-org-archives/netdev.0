From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: record TLP and ER timer stats in v6 stats
Date: Mon,  6 Jun 2016 15:07:18 -0700
Message-ID: <1465250838-13731-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, nanditad@google.com,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32905 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbcFFWHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 18:07:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id ec8so33316381pac.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 15:07:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The v6 tcp stats scan do not provide TLP and ER timer information
correctly like the v4 version . This patch fixes that.

Fixes: 6ba8a3b19e76 ("tcp: Tail loss probe (TLP)")
Fixes: eed530b6c676 ("tcp: early retransmit")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/tcp_ipv6.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4ad8edb..d1fc453 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1707,7 +1707,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	destp = ntohs(inet->inet_dport);
 	srcp  = ntohs(inet->inet_sport);
 
-	if (icsk->icsk_pending == ICSK_TIME_RETRANS) {
+	if (icsk->icsk_pending == ICSK_TIME_RETRANS ||
+	    icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
+	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
 		timer_active	= 1;
 		timer_expires	= icsk->icsk_timeout;
 	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
-- 
2.8.0.rc3.226.g39d4020
