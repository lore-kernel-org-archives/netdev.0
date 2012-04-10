From: pablo@netfilter.org
Subject: [PATCH 1/5] netfilter: nf_ct_tcp: don't scale the size of the window up twice
Date: Tue, 10 Apr 2012 14:48:57 +0200
Message-ID: <1334062141-3962-2-git-send-email-pablo@netfilter.org>
References: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334062141-3962-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

For a picked up connection, the window win is scaled twice: one is by the
initialization code, and the other is by the sender updating code.

I use the temporary variable swin instead of modifying the variable win.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

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
-- 
1.7.2.5

