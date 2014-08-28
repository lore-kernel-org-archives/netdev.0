From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: tell RXCHK if we are using Broadcom tags
Date: Thu, 28 Aug 2014 15:11:03 -0700
Message-ID: <1409263863-5364-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:60382 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbaH1WLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 18:11:38 -0400
Received: by mail-pa0-f43.google.com with SMTP id et14so4306171pad.16
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 15:11:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Broadcom tags are enabled, e.g: when interfaced to an Ethernet
switch, make sure that we tell the RXCHK engine that it should be
expecting a 4-bytes Broadcom tag after the Ethernet MAC Source Address.

Use netdev_uses_dsa() to check for that condition since that will tell
us if a switch is attached to our network interface.

Fixes: 80105befdb4b ("net: systemport: add Broadcom SYSTEMPORT Ethernet MAC driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 6f4e18644bd4..8f91de169663 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -139,6 +139,15 @@ static int bcm_sysport_set_rx_csum(struct net_device *dev,
 	else
 		reg &= ~RXCHK_SKIP_FCS;
 
+	/* If Broadcom tags are enabled (e.g: using a switch), make
+	 * sure we tell the RXCHK hardware to expect a 4-bytes Broadcom
+	 * tag after the Ethernet MAC Source Address.
+	 */
+	if (netdev_uses_dsa(dev))
+		reg |= RXCHK_BRCM_TAG_EN;
+	else
+		reg &= ~RXCHK_BRCM_TAG_EN;
+
 	rxchk_writel(priv, reg, RXCHK_CONTROL);
 
 	return 0;
-- 
1.9.1
