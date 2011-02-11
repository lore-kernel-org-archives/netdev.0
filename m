From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: enable wol via magic frame by default.
Date: Fri, 11 Feb 2011 09:51:46 +0100
Message-ID: <1297414306-11271-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:40260 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753119Ab1BKIv5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 03:51:57 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CC93D179
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 08:51:55 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas6.st.com [10.75.90.73])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 897D42786
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 08:51:55 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables it by default when the driver starts.
This has been required by many people and seems to actually be
useful on STB.
At any rate, the WoL modes can be selected and turned-on/off
by using the ethtool at run-time by users.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 34a0af3..0e5f031 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1560,8 +1560,10 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	priv->hw = device;
 
-	if (device_can_wakeup(priv->device))
+	if (device_can_wakeup(priv->device)) {
 		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
+		enable_irq_wake(dev->irq);
+	}
 
 	return 0;
 }
-- 
1.7.4
