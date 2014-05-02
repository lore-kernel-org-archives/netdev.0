From: George Cherian <george.cherian@ti.com>
Subject: [PATCH v2 4/6] drivers: net: cpsw: Enable Annexe F Time sync
Date: Fri, 2 May 2014 12:02:02 +0530
Message-ID: <1399012324-20737-5-git-send-email-george.cherian@ti.com>
References: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, tony@atomide.com, ast@plumgrid.com,
 mturquette@linaro.org, jeffrey.t.kirsher@intel.com, tklauser@distanz.ch,
 mugunthanvnm@ti.com, george.cherian@ti.com, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, richardcochran@gmail.com, robh+dt@kernel.org,
 bhutchings@solarflare.com, linux@arm.linux.org.uk, balbi@ti.com,
 zonque@gmail.com, t-kristo@ti.com, dborkman@redhat.com, bcousson@baylibre.com,
 galak@codeaurora.org, mpa@pengutronix.de, davem@davemloft.net
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <devicetree@vger.kernel.org>,
 <linux-omap@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
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

Enable the Annex F Time Sync explicitly for DRA7x and AM4372.
With this enabled the L2 PTP is working.

while at that rename TS_BIT8 to TS_TTL_NONZERO

Signed-off-by: George Cherian <george.cherian@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 49 +++++++++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 085ffb5..d14c8da 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -248,20 +248,31 @@ struct cpsw_ss_regs {
 #define TS_131              (1<<11) /* Time Sync Dest IP Addr 131 enable */
 #define TS_130              (1<<10) /* Time Sync Dest IP Addr 130 enable */
 #define TS_129              (1<<9)  /* Time Sync Dest IP Addr 129 enable */
-#define TS_BIT8             (1<<8)  /* ts_ttl_nonzero? */
+#define TS_TTL_NONZERO      (1<<8)  /* Time Sync Time To Live Non-zero enable */
+#define TS_ANNEX_F_EN       (1<<6)  /* Time Sync Annex F enable */
 #define TS_ANNEX_D_EN       (1<<4)  /* Time Sync Annex D enable */
 #define TS_LTYPE2_EN        (1<<3)  /* Time Sync LTYPE 2 enable */
 #define TS_LTYPE1_EN        (1<<2)  /* Time Sync LTYPE 1 enable */
 #define TS_TX_EN            (1<<1)  /* Time Sync Transmit Enable */
 #define TS_RX_EN            (1<<0)  /* Time Sync Receive Enable */
 
-#define CTRL_TS_BITS \
-	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 | TS_BIT8 | \
-	 TS_ANNEX_D_EN | TS_LTYPE1_EN)
+#define CTRL_V2_TS_BITS \
+	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 |\
+	 TS_TTL_NONZERO  | TS_ANNEX_D_EN | TS_LTYPE1_EN)
 
-#define CTRL_ALL_TS_MASK (CTRL_TS_BITS | TS_TX_EN | TS_RX_EN)
-#define CTRL_TX_TS_BITS  (CTRL_TS_BITS | TS_TX_EN)
-#define CTRL_RX_TS_BITS  (CTRL_TS_BITS | TS_RX_EN)
+#define CTRL_V2_ALL_TS_MASK (CTRL_V2_TS_BITS | TS_TX_EN | TS_RX_EN)
+#define CTRL_V2_TX_TS_BITS  (CTRL_V2_TS_BITS | TS_TX_EN)
+#define CTRL_V2_RX_TS_BITS  (CTRL_V2_TS_BITS | TS_RX_EN)
+
+
+#define CTRL_V3_TS_BITS \
+	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 |\
+	 TS_TTL_NONZERO | TS_ANNEX_F_EN | TS_ANNEX_D_EN |\
+	 TS_LTYPE1_EN)
+
+#define CTRL_V3_ALL_TS_MASK (CTRL_V3_TS_BITS | TS_TX_EN | TS_RX_EN)
+#define CTRL_V3_TX_TS_BITS  (CTRL_V3_TS_BITS | TS_TX_EN)
+#define CTRL_V3_RX_TS_BITS  (CTRL_V3_TS_BITS | TS_RX_EN)
 
 /* Bit definitions for the CPSW2_TS_SEQ_MTYPE register */
 #define TS_SEQ_ID_OFFSET_SHIFT   (16)    /* Time Sync Sequence ID Offset */
@@ -1376,13 +1387,27 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 		slave = &priv->slaves[priv->data.active_slave];
 
 	ctrl = slave_read(slave, CPSW2_CONTROL);
-	ctrl &= ~CTRL_ALL_TS_MASK;
+	switch (priv->version) {
+	case CPSW_VERSION_2:
+		ctrl &= ~CTRL_V2_ALL_TS_MASK;
 
-	if (priv->cpts->tx_enable)
-		ctrl |= CTRL_TX_TS_BITS;
+		if (priv->cpts->tx_enable)
+			ctrl |= CTRL_V2_TX_TS_BITS;
 
-	if (priv->cpts->rx_enable)
-		ctrl |= CTRL_RX_TS_BITS;
+		if (priv->cpts->rx_enable)
+			ctrl |= CTRL_V2_RX_TS_BITS;
+	break;
+	case CPSW_VERSION_3:
+	default:
+		ctrl &= ~CTRL_V3_ALL_TS_MASK;
+
+		if (priv->cpts->tx_enable)
+			ctrl |= CTRL_V3_TX_TS_BITS;
+
+		if (priv->cpts->rx_enable)
+			ctrl |= CTRL_V3_RX_TS_BITS;
+	break;
+	}
 
 	mtype = (30 << TS_SEQ_ID_OFFSET_SHIFT) | EVENT_MSG_BITS;
 
-- 
1.8.3.1
