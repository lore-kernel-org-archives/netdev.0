From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 35/54] vxge: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:21 -0700
Message-ID: <1395727540-12148-35-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58441 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaCYGL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:29 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in vxge_xmit that can
be called in hard irq and other contexts.

vxge_xmit only calls dev_kfree_skb_any when errors result in dropping
skbs.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 11adc89959c1..d107bcbb8543 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -824,7 +824,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->len <= 0)) {
 		vxge_debug_tx(VXGE_ERR,
 			"%s: Buffer has no data..", dev->name);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -833,7 +833,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(!is_vxge_card_up(vdev))) {
 		vxge_debug_tx(VXGE_ERR,
 			"%s: vdev not initialized", dev->name);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -843,7 +843,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 			vxge_debug_tx(VXGE_ERR,
 				"%s: Failed to store the mac address",
 				dev->name);
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			return NETDEV_TX_OK;
 		}
 	}
@@ -990,7 +990,7 @@ _exit1:
 	vxge_hw_fifo_txdl_free(fifo_hw, dtr);
 _exit0:
 	netif_tx_stop_queue(fifo->txq);
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
