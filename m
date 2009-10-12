From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/8] gianfar: Don't needlessly set the wrap bit for the
	last RX BD
Date: Mon, 12 Oct 2009 20:00:33 +0400
Message-ID: <20091012160033.GC2463@oksana.dev.rtsoft.ru>
References: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20091012160000.GA32406@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

startup_gfar() sets the wrap bit for the last rxbd just after
gfar_new_rxbdp() call, which is issued for all rxbds. And
gfar_new_rxbdp() has the following check already:

	if (bdp == priv->rx_bd_base + priv->rx_ring_size - 1)
		lstatus |= BD_LFLAG(RXBD_WRAP);

So we don't need to set the bit again.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b7881e6..ee23431 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1028,10 +1028,6 @@ int startup_gfar(struct net_device *ndev)
 		rxbdp++;
 	}
 
-	/* Set the last descriptor in the ring to wrap */
-	rxbdp--;
-	rxbdp->status |= RXBD_WRAP;
-
 	/* If the device has multiple interrupts, register for
 	 * them.  Otherwise, only register for the one */
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-- 
1.6.3.3
