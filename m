From: Feng King <kinwin2008@gmail.com>
Subject: [PATCH] tcp: Fix comments for Nagle algorithm
Date: Sat,  5 Nov 2011 22:23:23 +0800
Message-ID: <1320503003-5169-1-git-send-email-kinwin2008@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	Feng King <kinwin2008@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP_NODELAY is weaker than TCP_CORK, when TCP_CORK was set, small
segments will always pass Nagle test regardless of TCP_NODELAY option.

Signed-off-by: Feng King <kinwin2008@gmail.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 882e0b0..a908f95 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1377,7 +1377,7 @@ static inline int tcp_minshall_check(const struct tcp_sock *tp)
 /* Return 0, if packet can be sent now without violation Nagle's rules:
  * 1. It is full sized.
  * 2. Or it contains FIN. (already checked by caller)
- * 3. Or TCP_NODELAY was set.
+ * 3. Or TCP_CORK is not set, and TCP_NODELAY is set.
  * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
  *    With Minshall's modification: all sent small packets are ACKed.
  */
-- 
1.7.1
