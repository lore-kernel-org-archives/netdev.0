From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix under-accounting retransmit SNMP counters
Date: Wed, 21 Sep 2016 16:16:14 -0700
Message-ID: <1474499775-26436-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36174 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756969AbcIUXRr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:17:47 -0400
Received: by mail-pf0-f178.google.com with SMTP id q2so23712791pfj.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 16:17:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes these under-accounting SNMP rtx stats
LINUX_MIB_TCPFORWARDRETRANS
LINUX_MIB_TCPFASTRETRANS
LINUX_MIB_TCPSLOWSTARTRETRANS
when retransmitting TSO packets

Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 810be35..5725822 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2822,7 +2822,7 @@ begin_fwd:
 		if (tcp_retransmit_skb(sk, skb, segs))
 			return;
 
-		NET_INC_STATS(sock_net(sk), mib_idx);
+		NET_ADD_STATS(sock_net(sk), mib_idx, tcp_skb_pcount(skb));
 
 		if (tcp_in_cwnd_reduction(sk))
 			tp->prr_out += tcp_skb_pcount(skb);
-- 
2.8.0.rc3.226.g39d4020
