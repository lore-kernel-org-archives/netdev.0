From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [net-next 03/13] fsl/fman: small fixes
Date: Tue, 4 Oct 2016 10:32:49 +0300
Message-ID: <1475566379-5078-4-git-send-email-madalin.bucur@nxp.com>
References: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: madalin.bucur@nxp.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxdev.baldrick@gmail.com, linuxppc-dev@lists.ozlabs.org,
 davem@davemloft.net, linux-kernel@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1475566379-5078-1-git-send-email-madalin.bucur@nxp.com>
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

From: Madalin Bucur <madalin.bucur@freescale.com>

Make module params static, proper NULL checks, remove __iomem label
when misused.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/fman/fman.c      | 6 +++---
 drivers/net/ethernet/freescale/fman/fman_port.c | 8 +++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index ef5f228..fb25748 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -2462,7 +2462,7 @@ EXPORT_SYMBOL(fman_get_mem_region);
  * particular forwarding scenarios that add extra headers to the
  * forwarded frame.
  */
-int fsl_fm_rx_extra_headroom = FSL_FM_RX_EXTRA_HEADROOM;
+static int fsl_fm_rx_extra_headroom = FSL_FM_RX_EXTRA_HEADROOM;
 module_param(fsl_fm_rx_extra_headroom, int, 0);
 MODULE_PARM_DESC(fsl_fm_rx_extra_headroom, "Extra headroom for Rx buffers");
 
@@ -2475,7 +2475,7 @@ MODULE_PARM_DESC(fsl_fm_rx_extra_headroom, "Extra headroom for Rx buffers");
  * Could be overridden once, at boot-time, via the
  * fm_set_max_frm() callback.
  */
-int fsl_fm_max_frm = FSL_FM_MAX_FRAME_SIZE;
+static int fsl_fm_max_frm = FSL_FM_MAX_FRAME_SIZE;
 module_param(fsl_fm_max_frm, int, 0);
 MODULE_PARM_DESC(fsl_fm_max_frm, "Maximum frame size, across all interfaces");
 
@@ -2868,7 +2868,7 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 
 	fman->dts_params.base_addr =
 		devm_ioremap(&of_dev->dev, phys_base_addr, mem_size);
-	if (fman->dts_params.base_addr == 0) {
+	if (!fman->dts_params.base_addr) {
 		dev_err(&of_dev->dev, "%s: devm_ioremap() failed\n", __func__);
 		goto fman_free;
 	}
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index 6de808e..8b043e7 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -1477,7 +1477,8 @@ EXPORT_SYMBOL(fman_port_cfg_buf_prefix_content);
  */
 int fman_port_disable(struct fman_port *port)
 {
-	u32 __iomem *bmi_cfg_reg, *bmi_status_reg, tmp;
+	u32 __iomem *bmi_cfg_reg, *bmi_status_reg;
+	u32 tmp;
 	bool rx_port, failure = false;
 	int count;
 
@@ -1553,7 +1554,8 @@ EXPORT_SYMBOL(fman_port_disable);
  */
 int fman_port_enable(struct fman_port *port)
 {
-	u32 __iomem *bmi_cfg_reg, tmp;
+	u32 __iomem *bmi_cfg_reg;
+	u32 tmp;
 	bool rx_port;
 
 	if (!is_init_done(port->cfg))
@@ -1743,7 +1745,7 @@ static int fman_port_probe(struct platform_device *of_dev)
 
 	port->dts_params.base_addr = devm_ioremap(port->dev, res.start,
 						  resource_size(&res));
-	if (port->dts_params.base_addr == 0)
+	if (!port->dts_params.base_addr)
 		dev_err(port->dev, "%s: devm_ioremap() failed\n", __func__);
 
 	dev_set_drvdata(&of_dev->dev, port);
-- 
2.1.0
