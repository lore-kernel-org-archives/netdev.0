From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix typo in RX descriptor bit name
Date: Tue, 03 Nov 2015 01:28:07 +0300
Message-ID: <2943003.kyUQtQdRCT@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The correct name of the RX descriptor 0 bit 30 is RDLE (receive descriptor
list end),  not  RDEL.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the Dave Miller's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1173,7 +1173,7 @@ static void sh_eth_ring_format(struct ne
 	mdp->dirty_rx = (u32) (i - mdp->num_rx_ring);
 
 	/* Mark the last entry as wrapping the ring. */
-	rxdesc->status |= cpu_to_edmac(mdp, RD_RDEL);
+	rxdesc->status |= cpu_to_edmac(mdp, RD_RDLE);
 
 	memset(mdp->tx_ring, 0, tx_ringsize);
 
@@ -1547,7 +1547,7 @@ static int sh_eth_rx(struct net_device *
 		wmb(); /* RACT bit must be set after all the above writes */
 		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
-				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDEL);
+				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDLE);
 		else
 			rxdesc->status |=
 				cpu_to_edmac(mdp, RD_RACT | RD_RFP);
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -285,7 +285,7 @@ enum DMAC_IM_BIT {
 
 /* Receive descriptor bit */
 enum RD_STS_BIT {
-	RD_RACT = 0x80000000, RD_RDEL = 0x40000000,
+	RD_RACT = 0x80000000, RD_RDLE = 0x40000000,
 	RD_RFP1 = 0x20000000, RD_RFP0 = 0x10000000,
 	RD_RFE = 0x08000000, RD_RFS10 = 0x00000200,
 	RD_RFS9 = 0x00000100, RD_RFS8 = 0x00000080,

