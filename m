From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/2] stmmac: fix autoneg in set_pauseparam
Date: Fri, 13 May 2011 08:28:05 +0200
Message-ID: <1305268085-603-2-git-send-email-peppe.cavallaro@st.com>
References: <1305268085-603-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:51615 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753013Ab1EMG2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 02:28:45 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 08717197
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 06:28:42 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AEF4615C0
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 06:28:42 +0000 (GMT)
In-Reply-To: <1305268085-603-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug in the set_pauseparam
function that didn't well manage the ANE
field and returned broken values when use
ethtool -A|-a.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 9c05cf0..ae5213a 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -234,6 +234,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		new_pause |= FLOW_TX;
 
 	priv->flow_ctrl = new_pause;
+	phy->autoneg = pause->autoneg;
 
 	if (phy->autoneg) {
 		if (netif_running(netdev))
-- 
1.7.4.4

