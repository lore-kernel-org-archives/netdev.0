From: gfree.wind@foxmail.com
Subject: [PATCH net 1/1] net: tcp: Increase TCPABORTONLINGER when send RST by linger2 in keepalive timer
Date: Sun,  9 Apr 2017 20:44:41 +0800
Message-ID: <1491741881-28322-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, ncardwell@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgau1.qq.com ([54.206.16.166]:39464 "EHLO smtpbgau1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752069AbdDIMpL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 08:45:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

It should increase TCPABORTONLINGER counter when send RST caused by
linger2 in keepalive timer.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/tcp_timer.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b2ab411..5c01f21 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -650,6 +650,8 @@ static void tcp_keepalive_timer (unsigned long data)
 				tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
 				goto out;
 			}
+		} else {
+			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTONLINGER);
 		}
 		tcp_send_active_reset(sk, GFP_ATOMIC);
 		goto death;
-- 
1.9.1
