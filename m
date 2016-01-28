From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 08/40] net: fec: move cbd_bufaddr assignment closer
 to the mapping function
Date: Thu, 28 Jan 2016 14:25:32 -0700
Message-ID: <1454016364-30985-9-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 Troy Kisky <troy.kisky@boundarydevices.com>, laci@boundarydevices.com,
 l.stach@pengutronix.de, shawnguo@kernel.org,
 linux-arm-kernel@lists.infradead.org, tremyfr@gmail.com
To: netdev@vger.kernel.org,
	davem@davemloft.net,
	B38611@freescale.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b87f80d..15a93f90 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -476,6 +476,8 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 				estatus |= BD_ENET_TX_TS;
 		}
 	}
+	bdp->cbd_bufaddr = addr;
+	bdp->cbd_datlen = buflen;
 
 	if (fep->bufdesc_ex) {
 
@@ -499,8 +501,6 @@ static int fec_enet_txq_submit_skb(struct fec_enet_priv_tx_q *txq,
 	/* Save skb pointer */
 	txq->tx_skbuff[index] = skb;
 
-	bdp->cbd_datlen = buflen;
-	bdp->cbd_bufaddr = addr;
 	/* Make sure the updates to rest of the descriptor are performed before
 	 * transferring ownership.
 	 */
-- 
2.5.0
