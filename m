From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/4 linux-next] net: fec: use container_of to resolve bufdesc_ex from bufdesc
Date: Sat, 13 Sep 2014 22:38:26 +0200
Message-ID: <1410640709-18295-2-git-send-email-fabf@skynet.be>
References: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use container_of instead of casting first structure member.

ARM cross-compiled but untested.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 89355a7..f1a99d2 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -572,7 +572,7 @@ fec_enet_txq_put_data_tso(struct sk_buff *skb, struct net_device *ndev,
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
-	struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
 	unsigned short status;
 	unsigned int estatus = 0;
 	dma_addr_t addr;
@@ -631,7 +631,7 @@ fec_enet_txq_put_hdr_tso(struct sk_buff *skb, struct net_device *ndev,
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-	struct bufdesc_ex *ebdp = (struct bufdesc_ex *)bdp;
+	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
 	void *bufaddr;
 	unsigned long dmabuf;
 	unsigned short status;
-- 
1.8.4.5
