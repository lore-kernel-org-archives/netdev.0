From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 07/10] s2io: Enable UFO6 support.
Date: Wed, 17 Dec 2014 13:20:52 -0500
Message-ID: <1418840455-22598-8-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:62862 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaLQSV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:26 -0500
Received: by mail-qa0-f45.google.com with SMTP id i13so3774375qae.4
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:25 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jon Mason <jdmason@kudzu.us>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/neterion/s2io.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index f5e4b82..d823bb7 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -4140,7 +4140,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	frg_len = skb_headlen(skb);
-	if (offload_type == SKB_GSO_UDP) {
+	if (offload_type == SKB_GSO_UDP || offload_type == SKB_GSO_UDP6) {
 		int ufo_size;
 
 		ufo_size = s2io_udp_mss(skb);
@@ -7917,9 +7917,9 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	dev->features |= dev->hw_features |
 		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	if (sp->device_type & XFRAME_II_DEVICE) {
-		dev->hw_features |= NETIF_F_UFO;
+		dev->hw_features |= NETIF_F_ALL_UFO;
 		if (ufo)
-			dev->features |= NETIF_F_UFO;
+			dev->features |= NETIF_F_ALL_UFO;
 	}
 	if (sp->high_dma_flag == true)
 		dev->features |= NETIF_F_HIGHDMA;
-- 
1.9.3
