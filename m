From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] gre: fix return value of gre_rcv
Date: Wed, 23 Mar 2016 09:34:43 +0800
Message-ID: <1458696883-15796-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dropped skb's should be documented by an appropriate return value.
Use the correct NET_RX_DROP and NET_RX_SUCCESS values for that reason.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv4/ip_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 31936d3..1dc0cdb 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -432,12 +432,12 @@ static int gre_rcv(struct sk_buff *skb)
 		goto drop;
 
 	if (ipgre_rcv(skb, &tpi) == PACKET_RCVD)
-		return 0;
+		return NET_RX_SUCCESS;
 
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 drop:
 	kfree_skb(skb);
-	return 0;
+	return NET_RX_DROP;
 }
 
 static __sum16 gre_checksum(struct sk_buff *skb)
-- 
1.8.3.1
