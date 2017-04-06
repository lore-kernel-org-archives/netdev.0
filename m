From: gfree.wind@foxmail.com
Subject: [PATCH net 1/1] net: tcp: Don't increase the TCP_MIB_OUTRSTS when fail to transmit RST
Date: Thu,  6 Apr 2017 21:35:09 +0800
Message-ID: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg298.qq.com ([184.105.67.102]:50842 "EHLO smtpbg298.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933118AbdDFNn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 09:43:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When fail to transmit RST, don't increase TCP_MIB_OUTRSTS in func
tcp_send_active_reset like the case that it only increases
LINUX_MIB_TCPABORTFAILED when fail to alloc skb.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/tcp_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 22548b5..274802f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3014,8 +3014,8 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	/* Send it off. */
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
-
-	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
+	else
+		TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
 }
 
 /* Send a crossed SYN-ACK during socket establishment.
-- 
1.9.1
