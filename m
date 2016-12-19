From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net v2 3/5] fsl/fman: call of_platform_populate()
Date: Mon, 19 Dec 2016 11:22:21 +0200
Message-ID: <1482139343-8975-4-git-send-email-madalin.bucur@nxp.com>
References: <1482139343-8975-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <scott.wood@nxp.com>, <mpe@ellerman.id.au>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482139343-8975-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igal Liberman <igal.liberman@freescale.com>

Call of_platform_populate() to probe the FMan sub-nodes.

Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index dafd9e1..0b7f711 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2868,6 +2868,14 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 
 	fman->dev = &of_dev->dev;
 
+	/* call of_platform_populate in order to probe sub-nodes on arm64 */
+	err = of_platform_populate(fm_node, NULL, NULL, &of_dev->dev);
+	if (err) {
+		dev_err(&of_dev->dev, "%s: of_platform_populate() failed\n",
+			__func__);
+		goto fman_free;
+	}
+
 	return fman;
 
 fman_node_put:
-- 
2.1.0
