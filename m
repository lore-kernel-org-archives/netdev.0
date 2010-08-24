From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/3] stmmac: fix_mac_speed is called during 10/100<->1000 speed changes
Date: Tue, 24 Aug 2010 08:40:40 +0200
Message-ID: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
Cc: Pawel Moll <pawel.moll@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:34121 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755184Ab0HXNjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 09:39:04 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 67CAD106
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:39:01 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 25B3826A9
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:39:01 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pawel Moll <pawel.moll@st.com>

This patch modifies the stmmac_adjust_link() function so the
fix_mac_speed() is called not only when link speed is changing
between 10 and 100 Mbps (as required in RMII mode) but also
for 1000 Mbps.

Signed-off-by: Pawel Moll <pawel.moll@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index bbb7951..86b6c69 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -238,6 +238,9 @@ static void stmmac_adjust_link(struct net_device *dev)
 			case 1000:
 				if (likely(priv->is_gmac))
 					ctrl &= ~priv->hw->link.port;
+				if (likely(priv->fix_mac_speed))
+					priv->fix_mac_speed(priv->bsp_priv,
+							    phydev->speed);
 				break;
 			case 100:
 			case 10:
-- 
1.5.5.6

