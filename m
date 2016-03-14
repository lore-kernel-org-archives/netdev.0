From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 5/5] net: caif: fix misleading indentation
Date: Mon, 14 Mar 2016 15:18:38 +0100
Message-ID: <1457965120-3155420-6-git-send-email-arnd@arndb.de>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc points out code that is not indented the way it is
interpreted:

net/caif/cfpkt_skbuff.c: In function 'cfpkt_setlen':
net/caif/cfpkt_skbuff.c:289:4: error: statement is indented as if it were guarded by... [-Werror=misleading-indentation]
    return cfpkt_getlen(pkt);
    ^~~~~~
net/caif/cfpkt_skbuff.c:286:3: note: ...this 'else' clause, but it is not
   else
   ^~~~

It is clear from the context that not returning here would be
a bug, as we'd end up passing a negative length into a function
that takes a u16 length, so it is not missing curly braces
here, and I'm assuming that the indentation is the only part
that's wrong about it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/caif/cfpkt_skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index f6c3b2137eea..59ce1fcc220c 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -286,7 +286,7 @@ int cfpkt_setlen(struct cfpkt *pkt, u16 len)
 		else
 			skb_trim(skb, len);
 
-			return cfpkt_getlen(pkt);
+		return cfpkt_getlen(pkt);
 	}
 
 	/* Need to expand SKB */
-- 
2.7.0
