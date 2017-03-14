From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 4/5] sunvnet: count multicast packets
Date: Tue, 14 Mar 2017 10:24:42 -0700
Message-ID: <1489512283-422140-5-git-send-email-shannon.nelson@oracle.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure multicast packets get counted in the device.

Orabug: 25190537

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 5e1d016..0c35a9a 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -409,6 +409,8 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 
 	skb->ip_summed = port->switch_port ? CHECKSUM_NONE : CHECKSUM_PARTIAL;
 
+	if (unlikely(is_multicast_ether_addr(eth_hdr(skb)->h_dest)))
+		dev->stats.multicast++;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
 	port->stats.rx_packets++;
-- 
1.7.1
