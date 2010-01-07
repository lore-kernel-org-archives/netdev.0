From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 05/13] stmmac: perform hw bus configuration
Date: Thu,  7 Jan 2010 10:07:15 +0100
Message-ID: <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:54709 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756314Ab0AGJHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:30 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D0C66186
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:24 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7CAE0BC7
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:24 +0000 (GMT)
In-Reply-To: <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some platforms it can be required a different
configuration of the bus. This can be done
by invoking the bus_setup. It is defined
for all the platforms that needs this kind of
configuration.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/gmac.c        |    3 ---
 drivers/net/stmmac/stmmac_main.c |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/gmac.c b/drivers/net/stmmac/gmac.c
index 9828756..c127887 100644
--- a/drivers/net/stmmac/gmac.c
+++ b/drivers/net/stmmac/gmac.c
@@ -400,9 +400,6 @@ static void gmac_core_init(unsigned long ioaddr)
 	value |= GMAC_CORE_INIT;
 	writel(value, ioaddr + GMAC_CONTROL);
 
-	/* STBus Bridge Configuration */
-	/*writel(0xc5608, ioaddr + 0x00007000);*/
-
 	/* Freeze MMC counters */
 	writel(0x8, ioaddr + GMAC_MMC_CTRL);
 	/* Mask GMAC interrupts */
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index d50fe6f..a02006d 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1067,6 +1067,9 @@ static int stmmac_open(struct net_device *dev)
 
 	/* Copy the MAC addr into the HW  */
 	priv->mac_type->ops->set_umac_addr(ioaddr, dev->dev_addr, 0);
+	/* If required, perform hw setup of the bus. */
+	if (priv->bus_setup)
+		priv->bus_setup(ioaddr);
 	/* Initialize the MAC Core */
 	priv->mac_type->ops->core_init(ioaddr);
 
-- 
1.6.0.4

