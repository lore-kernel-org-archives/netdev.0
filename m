From: Marek Vasut <marek.vasut@gmail.com>
Subject: [PATCH] FEC: Rename dev to ndev, fix compile error
Date: Tue,  7 Feb 2012 23:42:28 +0100
Message-ID: <1328654548-28396-1-git-send-email-marek.vasut@gmail.com>
Cc: netdev@vger.kernel.org, Marek Vasut <marek.vasut@gmail.com>,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infreadead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40048 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756081Ab2BGWmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 17:42:38 -0500
Received: by eaah12 with SMTP id h12so2989350eaa.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 14:42:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following commit introduced a typo, this commit fixes it.

commit 21a4e46995fa1a76281ac0281ff837f706231a37
Author: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Date:   Sun Feb 5 02:50:10 2012 +0000

    netdev: ethernet dev_alloc_skb to netdev_alloc_skb

    Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
      - Removed extra skb->dev = dev after netdev_alloc_skb

Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
Cc: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/freescale/fec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index f976619..0ee2ca7 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -711,7 +711,7 @@ fec_enet_rx(struct net_device *ndev)
 		 * include that when passing upstream as it messes up
 		 * bridging applications.
 		 */
-		skb = netdev_alloc_skb(dev, pkt_len - 4 + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(ndev, pkt_len - 4 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
 			printk("%s: Memory squeeze, dropping packet.\n",
@@ -1210,7 +1210,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = netdev_alloc_skb(dev, FEC_ENET_RX_FRSIZE);
+		skb = netdev_alloc_skb(ndev, FEC_ENET_RX_FRSIZE);
 		if (!skb) {
 			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
-- 
1.7.8.3
