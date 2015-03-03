From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 08/14] appletalk: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:53 -0800
Message-ID: <d735626e32ec76e8b8e7b97120bcaa6b8025e434.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/appletalk/aarp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index d1c55d8..8ad3ec2 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -141,7 +141,7 @@ static void __aarp_send_query(struct aarp_entry *a)
 	eah->pa_src_net	 = sat->s_net;
 	eah->pa_src_node = sat->s_node;
 
-	memset(eah->hw_dst, '\0', ETH_ALEN);
+	eth_zero_addr(eah->hw_dst);
 
 	eah->pa_dst_zero = 0;
 	eah->pa_dst_net	 = a->target_addr.s_net;
@@ -189,7 +189,7 @@ static void aarp_send_reply(struct net_device *dev, struct atalk_addr *us,
 	eah->pa_src_node = us->s_node;
 
 	if (!sha)
-		memset(eah->hw_dst, '\0', ETH_ALEN);
+		eth_zero_addr(eah->hw_dst);
 	else
 		ether_addr_copy(eah->hw_dst, sha);
 
@@ -239,7 +239,7 @@ static void aarp_send_probe(struct net_device *dev, struct atalk_addr *us)
 	eah->pa_src_net	 = us->s_net;
 	eah->pa_src_node = us->s_node;
 
-	memset(eah->hw_dst, '\0', ETH_ALEN);
+	eth_zero_addr(eah->hw_dst);
 
 	eah->pa_dst_zero = 0;
 	eah->pa_dst_net	 = us->s_net;
-- 
2.1.2
