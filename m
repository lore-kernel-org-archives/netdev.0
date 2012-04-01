From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: don't do window scaling for a picked up connection
Date: Sun,  1 Apr 2012 23:04:43 +0800
Message-ID: <1333292683-31414-1-git-send-email-xiaosuo@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65298 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab2DAPHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 11:07:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For a picked up connection, the window scaling option is also lost, because this
option is only valid in SYN or SYN/ACK segments. We should remove the useless
expression to save the CPU power.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    1 -
 1 file changed, 1 deletion(-)
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 361eade..22f0500 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -584,7 +584,6 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			 * Let's try to use the data from the packet.
 			 */
 			sender->td_end = end;
-			win <<= sender->td_scale;
 			sender->td_maxwin = (win == 0 ? 1 : win);
 			sender->td_maxend = end + sender->td_maxwin;
 			/*
