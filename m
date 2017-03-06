From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 4/5] sunvnet: count multicast packets
Date: Mon,  6 Mar 2017 15:15:31 -0800
Message-ID: <1488842132-512058-5-git-send-email-shannon.nelson@oracle.com>
References: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42354 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752561AbdCFXYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 18:24:00 -0500
In-Reply-To: <1488842132-512058-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure multicast packets get counted in the device.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 8afc659..7eb53af 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -410,6 +410,8 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 
 	skb->ip_summed = port->switch_port ? CHECKSUM_NONE : CHECKSUM_PARTIAL;
 
+	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
+		dev->stats.multicast++;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 	port->stats.rx_packets++;
-- 
1.7.1
