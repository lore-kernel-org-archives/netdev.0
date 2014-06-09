From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 2/2] net: sh_eth: Fix timing of RACT setting in sh_eth_rx()
Date: Mon, 9 Jun 2014 19:39:24 +0900
Message-ID: <53958EDC.1070307@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes an issue that we cannot use nfs rootfs correctly
on r8a7790 when the command below runs on a host PC.

 $ sudo ping -f -l 8 $BOARD_IP_ADDR

Since the driver sets the RACT to 1 in the first while loop of
sh_eth_rx(), the controller accepts a next frame into the next RX
descriptor during the while loop. But, in the first while loop
doesn't allocate a next skb. So, this patch removes the RACT setting
in the first while loop of sh_eth_rx().

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ad0b5bd..2e1835f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1460,7 +1460,6 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes += pkt_len;
 		}
-		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
 		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
 	}
-- 
1.7.9.5

