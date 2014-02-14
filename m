From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: use ETH_ZLEN instead of home-grown #define
Date: Fri, 14 Feb 2014 03:05:42 +0300
Message-ID: <201402140305.42833.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver #define's and uses ETHERSMALL macro for the minimum Ethernet frame
size for which we have a standard macro ETH_ZLEN.  Use the latter  instead of
the home-grown one.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.h |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2098,8 +2098,8 @@ static int sh_eth_start_xmit(struct sk_b
 				 skb->len + 2);
 	txdesc->addr = dma_map_single(&ndev->dev, skb->data, skb->len,
 				      DMA_TO_DEVICE);
-	if (skb->len < ETHERSMALL)
-		txdesc->buffer_length = ETHERSMALL;
+	if (skb->len < ETH_ZLEN)
+		txdesc->buffer_length = ETH_ZLEN;
 	else
 		txdesc->buffer_length = skb->len;
 
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -27,8 +27,7 @@
 #define RX_RING_MIN	64
 #define TX_RING_MAX	1024
 #define RX_RING_MAX	1024
-#define ETHERSMALL		60
-#define PKT_BUF_SZ		1538
+#define PKT_BUF_SZ	1538
 #define SH_ETH_TSU_TIMEOUT_MS	500
 #define SH_ETH_TSU_CAM_ENTRIES	32
 
