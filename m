From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcpv6: fix option space offsets with md5
Date: Thu, 9 Oct 2008 00:31:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810090028040.8595@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1284535240-1223501383=:8595"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56654 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911AbYJHVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 17:35:36 -0400
Content-ID: <Pine.LNX.4.64.0810090030170.8595@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1284535240-1223501383=:8595
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810090030171.8595@wrl-59.cs.helsinki.fi>


More breakage :-), part of timestamps just were previously
overwritten.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/tcp_ipv6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26ac4fe..9c9ecf4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1087,7 +1087,7 @@ static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
 		*topt++ = htonl(tcp_time_stamp);
-		*topt = htonl(ts);
+		*topt++ = htonl(ts);
 	}
 
 #ifdef CONFIG_TCP_MD5SIG
-- 
1.5.2.2
---696208474-1284535240-1223501383=:8595--
