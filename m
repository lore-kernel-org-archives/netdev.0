From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: check the length of the data before dereferencing it
Date: Mon,  2 Apr 2012 11:10:50 +0800
Message-ID: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36853 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053Ab2DBDNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:13:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should check the length of the data before dereferencing it when parsing
the TCP options.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/tcp_input.c |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..5099f08 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3845,6 +3845,8 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 			length--;
 			continue;
 		default:
+			if (length < 2)
+				return;
 			opsize = *ptr++;
 			if (opsize < 2) /* "silly options" */
 				return;
