From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 6/7] stmmac: fix vlan support setup
Date: Wed, 14 Apr 2010 08:21:16 +0200
Message-ID: <1271226077-25882-6-git-send-email-peppe.cavallaro@st.com>
References: <1271226077-25882-1-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-2-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-3-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-4-git-send-email-peppe.cavallaro@st.com>
 <1271226077-25882-5-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:34181 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753764Ab0DNGVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 02:21:48 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 14294FB
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:46 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D3ECE11B1
	for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 06:21:45 +0000 (GMT)
In-Reply-To: <1271226077-25882-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moved STMMAC_VLAN_TAG_USED from stmmac.h to common.h header
because it is used within the device and descriptor cores.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/common.h |    5 +++++
 drivers/net/stmmac/stmmac.h |    5 -----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 27a05b4..144f76f 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -23,6 +23,11 @@
 *******************************************************************************/
 
 #include <linux/netdevice.h>
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#define STMMAC_VLAN_TAG_USED
+#include <linux/if_vlan.h>
+#endif
+
 #include "descs.h"
 
 #undef CHIP_DEBUG_PRINT
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 0d776bc..1a6eb7b 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -23,11 +23,6 @@
 #define DRV_MODULE_VERSION	"Jan_2010"
 #include <linux/stmmac.h>
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-#define STMMAC_VLAN_TAG_USED
-#include <linux/if_vlan.h>
-#endif
-
 #include "common.h"
 #ifdef CONFIG_STMMAC_TIMER
 #include "stmmac_timer.h"
-- 
1.6.0.4

