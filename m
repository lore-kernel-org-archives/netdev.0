From: George Cherian <george.cherian@ti.com>
Subject: [PATCH 4/6] drivers: net: cpsw: Enable Annexe F Time sync
Date: Mon, 28 Apr 2014 09:40:23 +0530
Message-ID: <1398658225-25873-5-git-send-email-george.cherian@ti.com>
References: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <richardcochran@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <dborkman@redhat.com>,
	<ast@plumgrid.com>, <tklauser@distanz.ch>, <mpa@pengutronix.de>,
	<bhutchings@solarflare.com>, <zonque@gmail.com>, <balbi@ti.com>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <t-kristo@ti.com>,
	<mturquette@linaro.org>, <linux@arm.linux.org.uk>,
	<galak@codeaurora.org>, <ijc+devicetree@hellion.org.uk>,
	<mark.rutland@arm.com>, <pawel.moll@arm.com>, <robh+dt@kernel.org>,
	<tony@atomide.com>, <bcousson@baylibre.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398658225-25873-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the Annex F Time Sync explicitly for DRA7x and AM4372.
With this enabled the L2 PTP is working.

while at that rename TS_BIT8 to TS_TTL_NONZERO

Signed-off-by: George Cherian <george.cherian@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 085ffb5..af1423b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -248,7 +248,8 @@ struct cpsw_ss_regs {
 #define TS_131              (1<<11) /* Time Sync Dest IP Addr 131 enable */
 #define TS_130              (1<<10) /* Time Sync Dest IP Addr 130 enable */
 #define TS_129              (1<<9)  /* Time Sync Dest IP Addr 129 enable */
-#define TS_BIT8             (1<<8)  /* ts_ttl_nonzero? */
+#define TS_TTL_NONZERO      (1<<8)  /* Time Sync Time To Live Non-zero enable */
+#define TS_ANNEX_F_EN       (1<<6)  /* Time Sync Annex F enable */
 #define TS_ANNEX_D_EN       (1<<4)  /* Time Sync Annex D enable */
 #define TS_LTYPE2_EN        (1<<3)  /* Time Sync LTYPE 2 enable */
 #define TS_LTYPE1_EN        (1<<2)  /* Time Sync LTYPE 1 enable */
@@ -256,8 +257,9 @@ struct cpsw_ss_regs {
 #define TS_RX_EN            (1<<0)  /* Time Sync Receive Enable */
 
 #define CTRL_TS_BITS \
-	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 | TS_BIT8 | \
-	 TS_ANNEX_D_EN | TS_LTYPE1_EN)
+	(TS_320 | TS_319 | TS_132 | TS_131 | TS_130 | TS_129 |\
+	 TS_TTL_NONZERO | TS_ANNEX_F_EN | TS_ANNEX_D_EN |\
+	 TS_LTYPE1_EN)
 
 #define CTRL_ALL_TS_MASK (CTRL_TS_BITS | TS_TX_EN | TS_RX_EN)
 #define CTRL_TX_TS_BITS  (CTRL_TS_BITS | TS_TX_EN)
-- 
1.8.3.1
