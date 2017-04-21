From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] net: tc35815: move free after the dereference
Date: Fri, 21 Apr 2017 13:49:37 +0300
Message-ID: <20170421104937.7sxibmruc6pvp26p@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Reynes <tremyfr@gmail.com>,
        Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26521 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037605AbdDUKtz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 06:49:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dereference "skb" to get "skb->len" so we should probably do that
step before freeing the skb.

Fixes: eea221ce4880 ("tc35815 driver update (take 2)")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index ad6db05b97d6..d9db8a06afd2 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -1017,8 +1017,8 @@ tc35815_free_queues(struct net_device *dev)
 			BUG_ON(lp->tx_skbs[i].skb != skb);
 #endif
 			if (skb) {
-				dev_kfree_skb(skb);
 				pci_unmap_single(lp->pci_dev, lp->tx_skbs[i].skb_dma, skb->len, PCI_DMA_TODEVICE);
+				dev_kfree_skb(skb);
 				lp->tx_skbs[i].skb = NULL;
 				lp->tx_skbs[i].skb_dma = 0;
 			}
