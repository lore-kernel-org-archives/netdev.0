From: fgao@ikuai8.com
Subject: [PATCH net 1/1] net: sock: Use double send/recv buff value to compare with max value
Date: Wed,  8 Feb 2017 21:07:15 +0800
Message-ID: <1486559235-13633-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG179.QQ.COM ([119.147.194.222]:36556 "EHLO
        smtpbg179.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbdBHNRO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 08:17:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Because the value of SO_SNDBUF and SO_RCVBUF is doubled before
assignment, so the real value of send and recv buffer could be more
than the max sysctl config sysctl_wmem_max and sysctl_rmem_max.

Now use doulbe send/recv buffer value to compare with sysctl_wmem_max
and sysctl_rmem_max, and it keeps consistence with SOCK_MIN_SNDBUF
and SOCK_MIN_RCVBUF.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/core/sock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 4eca27d..fa40dff 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -712,7 +712,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		 * play 'guess the biggest size' games. RCVBUF/SNDBUF
 		 * are treated in BSD as hints
 		 */
-		val = min_t(u32, val, sysctl_wmem_max);
+		val = min_t(u32, val * 2, sysctl_wmem_max);
 set_sndbuf:
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
 		sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);
@@ -733,7 +733,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		 * play 'guess the biggest size' games. RCVBUF/SNDBUF
 		 * are treated in BSD as hints
 		 */
-		val = min_t(u32, val, sysctl_rmem_max);
+		val = min_t(u32, val * 2, sysctl_rmem_max);
 set_rcvbuf:
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
 		/*
-- 
1.9.1
