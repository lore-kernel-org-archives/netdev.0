From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 6/8]  2.6.5-rc2 - sis190 update
Date: Sat, 27 Mar 2004 03:15:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040327031526.F31053@electric-eye.fr.zoreil.com>
References: <20040327030853.A30849@electric-eye.fr.zoreil.com> <20040327031131.A31053@electric-eye.fr.zoreil.com> <20040327031219.B31053@electric-eye.fr.zoreil.com> <20040327031302.C31053@electric-eye.fr.zoreil.com> <20040327031351.D31053@electric-eye.fr.zoreil.com> <20040327031443.E31053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040327031443.E31053@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 27, 2004 at 03:14:43AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Add dirty_rx (unused so far).


 drivers/net/sis190.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff -puN drivers/net/sis190.c~sis190-dma-api-rx-buffers-20 drivers/net/sis190.c
--- linux-2.6.5-rc2/drivers/net/sis190.c~sis190-dma-api-rx-buffers-20	2004-03-27 02:37:25.000000000 +0100
+++ linux-2.6.5-rc2-fr/drivers/net/sis190.c	2004-03-27 02:37:25.000000000 +0100
@@ -310,9 +310,10 @@ struct sis190_private {
 	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;	/* spin lock flag */
 	int chipset;
-	unsigned long cur_rx;	/* Index into the Rx descriptor buffer of next Rx pkt. */
-	unsigned long cur_tx;	/* Index into the Tx descriptor buffer of next Rx pkt. */
-	unsigned long dirty_tx;
+	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
+	u32 cur_tx; /* Index into the Tx descriptor buffer of next Tx pkt. */
+	u32 dirty_rx;
+	u32 dirty_tx;
 	dma_addr_t tx_dma;
 	dma_addr_t rx_dma;
 	struct TxDesc *TxDescArray;	/* Index of 256-alignment Tx Descriptor buffer */
@@ -854,7 +855,7 @@ static int SiS190_init_ring(struct net_d
 {
 	struct sis190_private *tp = dev->priv;
 
-	tp->cur_rx = 0;
+	tp->cur_rx = tp->dirty_rx = 0;
 	tp->cur_tx = tp->dirty_tx = 0;
 	memset(tp->TxDescArray, 0x0, NUM_TX_DESC * sizeof (struct TxDesc));
 	memset(tp->RxDescArray, 0x0, NUM_RX_DESC * sizeof (struct RxDesc));

_
