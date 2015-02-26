From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 4/5] sh_eth: Optionally log RX and TX status for
 each completed descriptor
Date: Thu, 26 Feb 2015 20:34:46 +0000
Message-ID: <1424982886.4444.75.camel@xylophone.i.decadent.org.uk>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46867 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbbBZUev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:34:51 -0500
In-Reply-To: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index e6248b1c3ad5..38b9d87b2667 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1414,6 +1414,9 @@ static int sh_eth_txfree(struct net_device *ndev)
 			break;
 		/* TACT bit must be checked before all the following reads */
 		rmb();
+		netif_info(mdp, tx_done, ndev,
+			   "tx entry %d status 0x%08x\n",
+			   entry, edmac_to_cpu(mdp, txdesc->status));
 		/* Free the original skb. */
 		if (mdp->tx_skbuff[entry]) {
 			dma_unmap_single(&ndev->dev, txdesc->addr,
@@ -1459,6 +1462,10 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 		if (--boguscnt < 0)
 			break;
 
+		netif_info(mdp, rx_status, ndev,
+			   "rx entry %d status 0x%08x len %d\n",
+			   entry, desc_status, pkt_len);
+
 		if (!(desc_status & RDFEND))
 			ndev->stats.rx_length_errors++;
 
-- 
1.7.10.4
