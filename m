From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 02/10] cxgb4vf: don't implement trivial (and incorrect) ndo_select_queue()
Date: Wed, 10 Nov 2010 18:04:04 -0800
Message-ID: <1289441052-4925-2-git-send-email-leedom@chelsio.com>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19117 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224Ab0KKCET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 21:04:19 -0500
In-Reply-To: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't implement (struct net_device_ops *)->ndo_select_queue() with simple
call to skb_tx_hash().  This leads to non-persistent TX queue selection in
the Linux dev_pick_tx() routine for TCP connections.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index f5259a1..224b36c 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1103,18 +1103,6 @@ static int cxgb4vf_set_mac_addr(struct net_device *dev, void *_addr)
 	return 0;
 }
 
-/*
- * Return a TX Queue on which to send the specified skb.
- */
-static u16 cxgb4vf_select_queue(struct net_device *dev, struct sk_buff *skb)
-{
-	/*
-	 * XXX For now just use the default hash but we probably want to
-	 * XXX look at other possibilities ...
-	 */
-	return skb_tx_hash(dev, skb);
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Poll all of our receive queues.  This is called outside of normal interrupt
@@ -2417,7 +2405,6 @@ static const struct net_device_ops cxgb4vf_netdev_ops	= {
 	.ndo_get_stats		= cxgb4vf_get_stats,
 	.ndo_set_rx_mode	= cxgb4vf_set_rxmode,
 	.ndo_set_mac_address	= cxgb4vf_set_mac_addr,
-	.ndo_select_queue	= cxgb4vf_select_queue,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl		= cxgb4vf_do_ioctl,
 	.ndo_change_mtu		= cxgb4vf_change_mtu,
@@ -2623,7 +2610,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		netdev->do_ioctl = cxgb4vf_do_ioctl;
 		netdev->change_mtu = cxgb4vf_change_mtu;
 		netdev->set_mac_address = cxgb4vf_set_mac_addr;
-		netdev->select_queue = cxgb4vf_select_queue;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 		netdev->poll_controller = cxgb4vf_poll_controller;
 #endif
-- 
1.7.0.4

