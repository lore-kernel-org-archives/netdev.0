From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: fsl: avoid 64-bit warning on pq_mdio
Date: Tue, 08 Dec 2015 16:17:29 +0100
Message-ID: <2847304.4thPqtFFJS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 Gerlando Falauto <gerlando.falauto@keymile.com>, linux-kernel@vger.kernel.org,
 Shaohui Xie <Shaohui.Xie@freescale.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

The pq_mdio driver can now be built for ARM64, where we get a format
string warning:

drivers/net/ethernet/freescale/fsl_pq_mdio.c: In function 'fsl_pq_mdio_probe':
drivers/net/ethernet/freescale/fsl_pq_mdio.c:467:25: warning: format '%x' expects argument of type 'unsigned int', but argument 3 has type 'long int' [-Wformat=]

The argument is an implicit ptrdiff_t from the subtraction of two pointers,
so we should use the %z format string modifier to make this work on 64-bit
architectures.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: fe761bcb9046 ("net: fsl: expands dependencies of NET_VENDOR_FREESCALE")
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 55c36230e176..40071dad1c57 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -464,7 +464,7 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 			 * address). Print error message but continue anyway.
 			 */
 			if ((void *)tbipa > priv->map + resource_size(&res) - 4)
-				dev_err(&pdev->dev, "invalid register map (should be at least 0x%04x to contain TBI address)\n",
+				dev_err(&pdev->dev, "invalid register map (should be at least 0x%04zx to contain TBI address)\n",
 					((void *)tbipa - priv->map) + 4);
 
 			iowrite32be(be32_to_cpup(prop), tbipa);
-- 
2.1.0.rc2
