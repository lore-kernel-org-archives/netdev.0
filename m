From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net: Unexport napi_gro_flush().
Date: Tue, 19 Jan 2010 14:12:55 -0800 (PST)
Message-ID: <20100119.141255.90146762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755077Ab0ASWMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 17:12:46 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0498C24C062
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 14:12:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nothing outside of net/core/dev.c uses it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 -
 net/core/dev.c            |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..468a11d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1527,7 +1527,6 @@ extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
-extern void		napi_gro_flush(struct napi_struct *napi);
 extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
 extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index a008f69..5747b9e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2582,7 +2582,7 @@ out:
 	return netif_receive_skb(skb);
 }
 
-void napi_gro_flush(struct napi_struct *napi)
+static void napi_gro_flush(struct napi_struct *napi)
 {
 	struct sk_buff *skb, *next;
 
@@ -2595,7 +2595,6 @@ void napi_gro_flush(struct napi_struct *napi)
 	napi->gro_count = 0;
 	napi->gro_list = NULL;
 }
-EXPORT_SYMBOL(napi_gro_flush);
 
 enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
-- 
1.6.5

