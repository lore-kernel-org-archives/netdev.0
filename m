From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/7] netpoll: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:18 -0800
Message-ID: <3e26b62d1ec7cc3de34efc4ca7651baed7e7f1e3.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/netpoll.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 19fe9c7..c03f3de 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -520,8 +520,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 		skb->protocol = eth->h_proto = htons(ETH_P_IP);
 	}
 
-	memcpy(eth->h_source, np->dev->dev_addr, ETH_ALEN);
-	memcpy(eth->h_dest, np->remote_mac, ETH_ALEN);
+	ether_addr_copy(eth->h_source, np->dev->dev_addr);
+	ether_addr_copy(eth->h_dest, np->remote_mac);
 
 	skb->dev = np->dev;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
