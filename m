From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Subject: [PATCH v2] ll_temac: Reset dma descriptors indexes on ndo_open
Date: Tue,  1 Oct 2013 08:17:10 +0200
Message-ID: <1380608230-29183-1-git-send-email-ricardo.ribalda@gmail.com>
Cc: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jingoo Han <jg1.han@samsung.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dma descriptors indexes are only initialized on the probe function.

If a packet is on the buffer when temac_stop is called, the dma
descriptors indexes can be left on a incorrect state where no other
package can be sent.

So an interface could be left in an usable state after ifdow/ifup.

This patch makes sure that the descriptors indexes are in a proper
status when the device is open.

Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
---
v2: As suggested by David Miller:

- Remove unneded app0=0 on dma descriptors
- Move all code to temac_dma_bd_init
- Fix changelog

 drivers/net/ethernet/xilinx/ll_temac_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index b88121f..0029148 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -297,6 +297,12 @@ static int temac_dma_bd_init(struct net_device *ndev)
 		       lp->rx_bd_p + (sizeof(*lp->rx_bd_v) * (RX_BD_NUM - 1)));
 	lp->dma_out(lp, TX_CURDESC_PTR, lp->tx_bd_p);
 
+	/* Init descriptor indexes */
+	lp->tx_bd_ci = 0;
+	lp->tx_bd_next = 0;
+	lp->tx_bd_tail = 0;
+	lp->rx_bd_ci = 0;
+
 	return 0;
 
 out:
-- 
1.8.4.rc3
