From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [net-next.git 2/3] stmmac: remove STMMAC_DEBUG_FS
Date: Wed, 15 Oct 2014 10:25:30 +0200
Message-ID: <1413361531-9182-3-git-send-email-peppe.cavallaro@st.com>
References: <1413361531-9182-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:36085 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751458AbaJOIat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 04:30:49 -0400
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s9F8FMjL009123
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 10:30:47 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1q0ee72u40-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 10:30:34 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 90EFE43
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 08:30:09 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9E28E2CD5D
	for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 08:30:31 +0000 (GMT)
In-Reply-To: <1413361531-9182-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the STMMAC_DEBUG_FS Koption is now removed from the
driver configuration and this support will be built
by default when DEBUG_FS is present. This can also be
useful on building driver verification.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig       |    8 --------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   14 +++++++-------
 2 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 40f356d..af5228a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -38,14 +38,6 @@ config STMMAC_PCI
 
 	  If unsure, say N.
 
-config STMMAC_DEBUG_FS
-	bool "Enable monitoring via sysFS "
-	default n
-	depends on STMMAC_ETH && DEBUG_FS
-	---help---
-	  The stmmac entry in /sys reports DMA TX/RX rings
-	  or (if supported) the HW cap register.
-
 config STMMAC_DA
 	bool "STMMAC DMA arbitration scheme"
 	default n
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6f77a46..a34754b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -44,10 +44,10 @@
 #include <linux/slab.h>
 #include <linux/prefetch.h>
 #include <linux/pinctrl/consumer.h>
-#ifdef CONFIG_STMMAC_DEBUG_FS
+#ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
-#endif /* CONFIG_STMMAC_DEBUG_FS */
+#endif /* CONFIG_DEBUG_FS */
 #include <linux/net_tstamp.h>
 #include "stmmac_ptp.h"
 #include "stmmac.h"
@@ -116,7 +116,7 @@ MODULE_PARM_DESC(chain_mode, "To use chain instead of ring mode");
 
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 
-#ifdef CONFIG_STMMAC_DEBUG_FS
+#ifdef CONFIG_DEBUG_FS
 static int stmmac_init_fs(struct net_device *dev);
 static void stmmac_exit_fs(void);
 #endif
@@ -1688,7 +1688,7 @@ static int stmmac_hw_setup(struct net_device *dev)
 	if (ret && ret != -EOPNOTSUPP)
 		pr_warn("%s: failed PTP initialisation\n", __func__);
 
-#ifdef CONFIG_STMMAC_DEBUG_FS
+#ifdef CONFIG_DEBUG_FS
 	ret = stmmac_init_fs(dev);
 	if (ret < 0)
 		pr_warn("%s: failed debugFS registration\n", __func__);
@@ -1866,7 +1866,7 @@ static int stmmac_release(struct net_device *dev)
 
 	netif_carrier_off(dev);
 
-#ifdef CONFIG_STMMAC_DEBUG_FS
+#ifdef CONFIG_DEBUG_FS
 	stmmac_exit_fs();
 #endif
 
@@ -2453,7 +2453,7 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return ret;
 }
 
-#ifdef CONFIG_STMMAC_DEBUG_FS
+#ifdef CONFIG_DEBUG_FS
 static struct dentry *stmmac_fs_dir;
 static struct dentry *stmmac_rings_status;
 static struct dentry *stmmac_dma_cap;
@@ -2638,7 +2638,7 @@ static void stmmac_exit_fs(void)
 	debugfs_remove(stmmac_dma_cap);
 	debugfs_remove(stmmac_fs_dir);
 }
-#endif /* CONFIG_STMMAC_DEBUG_FS */
+#endif /* CONFIG_DEBUG_FS */
 
 static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_open = stmmac_open,
-- 
1.7.4.4
