From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: [PATCH 3/5] net: sh_eth: fix receive desciptor loop
Date: Mon, 25 May 2009 18:53:40 +0900
Message-ID: <4A1A6AA4.3030507@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the problem that this driver not update rxdesc in sh_eth_rx.

Signed-off-by: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/sh_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index eb76835..728c419 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -536,6 +536,7 @@ static int sh_eth_rx(struct net_device *ndev)
 		}
 		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
 		entry = (++mdp->cur_rx) % RX_RING_SIZE;
+		rxdesc = &mdp->rx_ring[entry];
 	}

 	/* Refill the Rx ring buffers. */
-- 
1.5.5

