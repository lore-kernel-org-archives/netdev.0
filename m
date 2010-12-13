From: Yoichi Yuasa <yuasa@linux-mips.org>
Subject: [PATCH net-next-2.6 2/2] cpmac: fix warning length cast
Date: Mon, 13 Dec 2010 17:18:45 +0900
Message-ID: <20101213171845.39a2151f.yuasa@linux-mips.org>
References: <20101213171725.2ed299cf.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yuasa@linux-mips.org, netdev <netdev@vger.kernel.org>,
	Eugene Konev <ejka@imfi.kspu.ru>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:40907 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793Ab0LMIUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 03:20:10 -0500
Received: by gxk19 with SMTP id 19so3767689gxk.11
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 00:20:09 -0800 (PST)
In-Reply-To: <20101213171725.2ed299cf.yuasa@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/cpmac.c: In function 'cpmac_start_xmit':
drivers/net/cpmac.c:569: warning: comparison of distinct pointer types
lacks a cast

Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
---
 drivers/net/cpmac.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 8021756..3b606a5 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -180,7 +180,7 @@ struct cpmac_desc {
 	u32 hw_next;
 	u32 hw_data;
 	u16 bufflags;
-	u16 datalen;
+	size_t datalen;
 	u16 dataflags;
 #define CPMAC_SOP			0x8000
 #define CPMAC_EOP			0x4000
@@ -554,7 +554,8 @@ fatal_error:
 
 static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int queue, len;
+	int queue;
+	size_t len;
 	struct cpmac_desc *desc;
 	struct cpmac_priv *priv = netdev_priv(dev);
 
@@ -564,7 +565,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb_padto(skb, ETH_ZLEN)))
 		return NETDEV_TX_OK;
 
-	len = max(skb->len, ETH_ZLEN);
+	len = max_t(size_t, skb->len, ETH_ZLEN);
 	queue = skb_get_queue_mapping(skb);
 	netif_stop_subqueue(dev, queue);
 
-- 
1.7.3.3

