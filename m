From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net 2/4] fsl/fman: arm: call of_platform_populate() for arm64
 platfrom
Date: Thu, 15 Dec 2016 15:11:35 +0200
Message-ID: <1481807497-4724-3-git-send-email-madalin.bucur@nxp.com>
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

From: Igal Liberman <igal.liberman@freescale.com>

Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/fman.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index dafd9e1..f36b4eb 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2868,6 +2868,16 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 
 	fman->dev = &of_dev->dev;
 
+#ifdef CONFIG_ARM64
+	/* call of_platform_populate in order to probe sub-nodes on arm64 */
+	err = of_platform_populate(fm_node, NULL, NULL, &of_dev->dev);
+	if (err) {
+		dev_err(&of_dev->dev, "%s: of_platform_populate() failed\n",
+			__func__);
+		goto fman_free;
+	}
+#endif
+
 	return fman;
 
 fman_node_put:
-- 
2.1.0
