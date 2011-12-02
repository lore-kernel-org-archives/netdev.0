From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] ll_temac: Use kcalloc instead of kzalloc to allocate array
Date: Fri, 02 Dec 2011 23:35:43 +0100
Message-ID: <1322865343.1534.356.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advantage of kcalloc is, that will prevent integer overflows which could
result from the multiplication of number of elements and size and it is also
a bit nicer to read.

The semantic patch that makes this change is available
in https://lkml.org/lkml/2011/11/25/107

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c 2011-11-28 19:36:47.733440944 +0100
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c 2011-11-28 19:53:34.187365029 +0100
@@ -237,7 +237,7 @@ static int temac_dma_bd_init(struct net_
 	struct sk_buff *skb;
 	int i;
 
-	lp->rx_skb = kzalloc(sizeof(*lp->rx_skb) * RX_BD_NUM, GFP_KERNEL);
+	lp->rx_skb = kcalloc(RX_BD_NUM, sizeof(*lp->rx_skb), GFP_KERNEL);
 	if (!lp->rx_skb) {
 		dev_err(&ndev->dev,
 				"can't allocate memory for DMA RX buffer\n");
