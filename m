From: gfree.wind@foxmail.com
Subject: [PATCH net v2 1/1] net: tcp: Increase TCP_MIB_OUTRSTS even though fail to alloc skb
Date: Thu,  6 Apr 2017 23:05:49 +0800
Message-ID: <1491491149-30701-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, ncardwell@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau1.qq.com ([54.206.16.166]:59339 "EHLO smtpbgau1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934707AbdDFPG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 11:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Because TCP_MIB_OUTRSTS is an important count, so always increase it
whatever send it successfully or not.

Now move the increment of TCP_MIB_OUTRSTS to the top of
tcp_send_active_reset to make sure it is increased always even though
fail to alloc skb.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Always increase TCP_MIB_OUTRSTS, per Neal
 v1: initial version

 net/ipv4/tcp_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 22548b5..c3c082e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2999,6 +2999,8 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 {
 	struct sk_buff *skb;
 
+	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
+
 	/* NOTE: No TCP options attached and we never retransmit this. */
 	skb = alloc_skb(MAX_TCP_HEADER, priority);
 	if (!skb) {
@@ -3014,8 +3016,6 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	/* Send it off. */
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
-
-	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
 }
 
 /* Send a crossed SYN-ACK during socket establishment.
-- 
1.9.1



.
