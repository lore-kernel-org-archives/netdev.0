From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [Patch v3 1/5] fsl/qe: add rx_sync and tx_sync for TDM mode
Date: Mon, 6 Jun 2016 14:29:58 +0800
Message-ID: <1465194602-43209-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <xiaobo.xie@nxp.com>,
	Zhao Qiang <qiang.zhao@nxp.com>
To: <oss@buserror.net>, <davem@davemloft.net>,
	<Joakim.Tjernlund@infinera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rx_sync and tx_sync are used by QE-TDM mode,
add them to struct ucc_fast_info.

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
Changes for v2:
	- use strcmp instead of strcasecmp
Changes for v3:
	- na 

 drivers/soc/fsl/qe/qe.c       | 6 ++++++
 include/soc/fsl/qe/qe.h       | 2 ++
 include/soc/fsl/qe/ucc_fast.h | 2 ++
 3 files changed, 10 insertions(+)

diff --git a/drivers/soc/fsl/qe/qe.c b/drivers/soc/fsl/qe/qe.c
index 709fc63..7026507 100644
--- a/drivers/soc/fsl/qe/qe.c
+++ b/drivers/soc/fsl/qe/qe.c
@@ -239,6 +239,12 @@ enum qe_clock qe_clock_source(const char *source)
 	if (strcasecmp(source, "none") == 0)
 		return QE_CLK_NONE;
 
+	if (strcmp(source, "tsync_pin") == 0)
+		return QE_TSYNC_PIN;
+
+	if (strcmp(source, "rsync_pin") == 0)
+		return QE_RSYNC_PIN;
+
 	if (strncasecmp(source, "brg", 3) == 0) {
 		i = simple_strtoul(source + 3, NULL, 10);
 		if ((i >= 1) && (i <= 16))
diff --git a/include/soc/fsl/qe/qe.h b/include/soc/fsl/qe/qe.h
index 33b29ea..f918745 100644
--- a/include/soc/fsl/qe/qe.h
+++ b/include/soc/fsl/qe/qe.h
@@ -80,6 +80,8 @@ enum qe_clock {
 	QE_CLK22,		/* Clock 22 */
 	QE_CLK23,		/* Clock 23 */
 	QE_CLK24,		/* Clock 24 */
+	QE_RSYNC_PIN,		/* RSYNC from pin */
+	QE_TSYNC_PIN,		/* TSYNC from pin */
 	QE_CLK_DUMMY
 };
 
diff --git a/include/soc/fsl/qe/ucc_fast.h b/include/soc/fsl/qe/ucc_fast.h
index df8ea79..31548b7 100644
--- a/include/soc/fsl/qe/ucc_fast.h
+++ b/include/soc/fsl/qe/ucc_fast.h
@@ -120,6 +120,8 @@ struct ucc_fast_info {
 	int ucc_num;
 	enum qe_clock rx_clock;
 	enum qe_clock tx_clock;
+	enum qe_clock rx_sync;
+	enum qe_clock tx_sync;
 	u32 regs;
 	int irq;
 	u32 uccm_mask;
-- 
2.1.0.27.g96db324
