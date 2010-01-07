From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 06/13] stmmac: do not call fix_mac_speed if NULL
Date: Thu,  7 Jan 2010 10:07:16 +0100
Message-ID: <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:42553 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756329Ab0AGJHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:30 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3D00113C
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:25 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C0EFDBE2
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:24 +0000 (GMT)
In-Reply-To: <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some platforms, fix_mac_speed is used for
configuring some sysconf registers according
to the working speed.
This patch fixes the fix_mac_speed invocation
that cannot be done if it is a NULL pointer.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a02006d..82ebbc0 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -258,8 +258,9 @@ static void stmmac_adjust_link(struct net_device *dev)
 				} else {
 					ctrl &= ~priv->mac_type->hw.link.port;
 				}
-				priv->fix_mac_speed(priv->bsp_priv,
-						    phydev->speed);
+				if (likely(priv->fix_mac_speed))
+					priv->fix_mac_speed(priv->bsp_priv,
+							    phydev->speed);
 				break;
 			default:
 				if (netif_msg_link(priv))
-- 
1.6.0.4

