From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: don't scale the size of the window up twice
Date: Mon,  2 Apr 2012 11:25:06 +0800
Message-ID: <1333337106-8279-1-git-send-email-xiaosuo@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For a picked up connection, the window win is scaled twice: one is by the
initialization code, and the other is by the sender updating code.

I use the temporary variable swin instead of modifying the variable win.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 361eade..0d07a1d 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -584,8 +584,8 @@ static bool tcp_in_window(const struct nf_conn *ct,
 			 * Let's try to use the data from the packet.
 			 */
 			sender->td_end = end;
-			win <<= sender->td_scale;
-			sender->td_maxwin = (win == 0 ? 1 : win);
+			swin = win << sender->td_scale;
+			sender->td_maxwin = (swin == 0 ? 1 : swin);
 			sender->td_maxend = end + sender->td_maxwin;
 			/*
 			 * We haven't seen traffic in the other direction yet
