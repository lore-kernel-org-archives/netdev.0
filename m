From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] gianfar: fix compile warning
Date: Wed, 17 Oct 2007 21:54:58 -0600
Message-ID: <20071018035458.22355.99460.stgit@trillian.cg.shawcable.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li Yang <leoli@freescale.com>, Jeff Garzik <jeff@garzik.org>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>

Eliminate an uninitialized variable warning.  The code is correct, but
a pointer to the automatic variable 'addr' is passed to dma_alloc_coherent.
Since addr has never been initialized, and the compiler doesn't know
what dma_alloc_coherent will do with it, it complains.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index cc288d8..c009ab6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -696,7 +696,7 @@ int startup_gfar(struct net_device *dev)
 {
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
-	dma_addr_t addr;
+	dma_addr_t addr = 0;
 	unsigned long vaddr;
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
