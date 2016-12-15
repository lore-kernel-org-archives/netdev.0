From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 3/4] fsl/fman: A007273 only applies to PPC SoCs
Date: Thu, 15 Dec 2016 15:11:36 +0200
Message-ID: <1481807497-4724-4-git-send-email-madalin.bucur@nxp.com>
References: <1481807497-4724-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1481807497-4724-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
Reviewed-by: Camelia Groza <camelia.groza@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index f36b4eb..93d6a36 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -1890,6 +1890,7 @@ static int fman_reset(struct fman *fman)
 
 		goto _return;
 	} else {
+#ifdef CONFIG_PPC
 		struct device_node *guts_node;
 		struct ccsr_guts __iomem *guts_regs;
 		u32 devdisr2, reg;
@@ -1921,6 +1922,7 @@ static int fman_reset(struct fman *fman)
 
 		/* Enable all MACs */
 		iowrite32be(reg, &guts_regs->devdisr2);
+#endif
 
 		/* Perform FMan reset */
 		iowrite32be(FPM_RSTC_FM_RESET, &fman->fpm_regs->fm_rstc);
@@ -1932,25 +1934,31 @@ static int fman_reset(struct fman *fman)
 		} while (((ioread32be(&fman->fpm_regs->fm_rstc)) &
 			 FPM_RSTC_FM_RESET) && --count);
 		if (count == 0) {
+#ifdef CONFIG_PPC
 			iounmap(guts_regs);
 			of_node_put(guts_node);
+#endif
 			err = -EBUSY;
 			goto _return;
 		}
+#ifdef CONFIG_PPC
 
 		/* Restore devdisr2 value */
 		iowrite32be(devdisr2, &guts_regs->devdisr2);
 
 		iounmap(guts_regs);
 		of_node_put(guts_node);
+#endif
 
 		goto _return;
 
+#ifdef CONFIG_PPC
 guts_regs:
 		of_node_put(guts_node);
 guts_node:
 		dev_dbg(fman->dev, "%s: Didn't perform FManV3 reset due to Errata A007273!\n",
 			__func__);
+#endif
 	}
 _return:
 	return err;
-- 
2.1.0
