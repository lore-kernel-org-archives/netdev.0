From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 1/5] sh_eth: Implement multicast statistic based on
 the RFS8 status bit
Date: Thu, 26 Feb 2015 20:33:30 +0000
Message-ID: <1424982810.4444.72.camel@xylophone.i.decadent.org.uk>
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
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46756 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbbBZUdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:33:37 -0500
In-Reply-To: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least on the R8A7790, RFS8 reflects the RINT8 (multicast) MAC
status flag.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
This should probably wait for confirmation that RFS8 consistently
indicates a multicast frame.

Ben.

 drivers/net/ethernet/renesas/sh_eth.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 07c537d900da..4169f93b5c3c 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1497,6 +1497,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			netif_receive_skb(skb);
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes += pkt_len;
+			if (desc_status & RD_RFS8)
+				ndev->stats.multicast++;
 		}
 		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
-- 
1.7.10.4
