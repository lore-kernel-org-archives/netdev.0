From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 11/27] sky2: use __vlan_hwaccel helpers
Date: Tue, 13 Dec 2016 01:12:35 +0100 (CET)
Message-ID: <b3ab739fefa724ee75c6b76c4e87c5de4bf9704c.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Mirko Lindner <mlindner@marvell.com> (maintainer:MARVELL GIGABIT
        ETHERNET DRIVERS (skge/sky2)),
        Stephen Hemminger <stephen@networkplumber.org> (maintainer:MARVELL
        GIGABIT ETHERNET DRIVERS (skge/sky2))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50228 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753363AbcLMAMk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:40 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ethernet/marvell/sky2.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index b60ad0e..bcd20e0 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2485,13 +2485,11 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
 		skb_copy_hash(skb, re->skb);
-		skb->vlan_proto = re->skb->vlan_proto;
-		skb->vlan_tci = re->skb->vlan_tci;
+		__vlan_hwaccel_copy_tag(skb, re->skb);
 
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
 					       length, PCI_DMA_FROMDEVICE);
-		re->skb->vlan_proto = 0;
-		re->skb->vlan_tci = 0;
+		__vlan_hwaccel_clear_tag(re->skb);
 		skb_clear_hash(re->skb);
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
-- 
2.10.2
