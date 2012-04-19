From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/6] tcp: Report mss_clamp with TCP_MAXSEG option in repair
 mode
Date: Thu, 19 Apr 2012 17:41:32 +0400
Message-ID: <4F90160C.1070605@parallels.com>
References: <4F901572.4040009@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28464 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab2DSNlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:41:39 -0400
In-Reply-To: <4F901572.4040009@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mss_clamp is the only connection-time negotiated option which
cannot be obtained from the user space. Make the TCP_MAXSEG sockopt
report one in the repair mode.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/tcp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 47e2f49..b4e690d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2659,6 +2659,8 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = tp->mss_cache;
 		if (!val && ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN)))
 			val = tp->rx_opt.user_mss;
+		if (tp->repair)
+			val = tp->rx_opt.mss_clamp;
 		break;
 	case TCP_NODELAY:
 		val = !!(tp->nonagle&TCP_NAGLE_OFF);
-- 
1.5.5.6
