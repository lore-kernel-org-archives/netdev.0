From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v2 1/1] net: fec: fix receive VLAN CTAG HW acceleration issue
Date: Tue, 10 Mar 2015 19:09:41 +0800
Message-ID: <1425985781-25736-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <kernel@pengutronix.de>,
	<b38611@freescale.com>
To: <mgr@pengutronix.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0114.outbound.protection.outlook.com ([157.56.110.114]:5917
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750848AbbCJLPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 07:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current driver support receive VLAN CTAG HW acceleration feature
(NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls the
api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but there
have overlap between the two memory data point range. The patch just fix
the issue.

V2:
Michael Grzeschik suggest to use memmove() instead of skb_copy_to_linear_data_offset().

Reported-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9bb6220..92b7e9a 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1479,8 +1479,7 @@ fec_enet_rx_queue(struct net_device *ndev, int budget, u16 queue_id)
 
 			vlan_packet_rcvd = true;
 
-			skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
-						       data, (2 * ETH_ALEN));
+			memmove(skb->data + VLAN_HLEN, data, ETH_ALEN * 2);
 			skb_pull(skb, VLAN_HLEN);
 		}
 
-- 
1.7.8
