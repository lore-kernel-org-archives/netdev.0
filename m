From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 8/9] net: stmmac: restore pinstate in pm resume.
Date: Mon, 18 Nov 2013 11:32:23 +0000
Message-ID: <1384774343-10388-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <srinivas.kandagatla@st.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:55609 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751057Ab3KRLeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 06:34:11 -0500
In-Reply-To: <1384774256-10039-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds code to restore default pinstate of the pins when it
comes back from low power state. Without this patch the state of the
pins would be unknown and the driver would not work.

This patch also adds code to put the pins in to sleep state when the
driver enters low power state.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5b4bd7d..c0b5716 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -43,6 +43,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
 #include <linux/prefetch.h>
+#include <linux/pinctrl/consumer.h>
 #ifdef CONFIG_STMMAC_DEBUG_FS
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
@@ -2853,6 +2854,7 @@ int stmmac_suspend(struct net_device *ndev)
 		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
 	else {
 		stmmac_set_mac(priv->ioaddr, false);
+		pinctrl_pm_select_sleep_state(priv->device);
 		/* Disable clock in case of PWM is off */
 		clk_disable_unprepare(priv->stmmac_clk);
 	}
@@ -2879,6 +2881,7 @@ int stmmac_resume(struct net_device *ndev)
 	if (device_may_wakeup(priv->device)) {
 		priv->hw->mac->pmt(priv->ioaddr, 0);
 	} else {
+		pinctrl_pm_select_default_state(priv->device);
 		/* enable the clk prevously disabled */
 		clk_prepare_enable(priv->stmmac_clk);
 		/* reset the phy so that it's ready */
-- 
1.7.6.5
