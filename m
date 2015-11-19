From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net 2/2] tcp: fix Fast Open snmp over-counting bug
Date: Wed, 18 Nov 2015 18:17:31 -0800
Message-ID: <1447899451-24584-2-git-send-email-ycheng@google.com>
References: <1447899451-24584-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36072 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756239AbbKSCSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 21:18:15 -0500
Received: by pacdm15 with SMTP id dm15so63961906pac.3
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 18:18:15 -0800 (PST)
In-Reply-To: <1447899451-24584-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incrementing TCPFastOpenActiveFailed snmp stats multiple times
when the handshake experiences multiple SYN timeouts.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_timer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 448603a..193ba1f 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -168,7 +168,7 @@ static int tcp_write_timeout(struct sock *sk)
 			dst_negative_advice(sk);
 			if (tp->syn_fastopen || tp->syn_data)
 				tcp_fastopen_cache_set(sk, 0, NULL, true, 0);
-			if (tp->syn_data)
+			if (tp->syn_data && icsk->icsk_retransmits == 1)
 				NET_INC_STATS_BH(sock_net(sk),
 						 LINUX_MIB_TCPFASTOPENACTIVEFAIL);
 		}
-- 
2.6.0.rc2.230.g3dd15c0
