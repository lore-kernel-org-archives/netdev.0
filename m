From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 4/4] Altera TSE: Change driver name used by Ethtool
Date: Thu, 24 Apr 2014 16:58:11 -0500
Message-ID: <1398376691-15265-5-git-send-email-vbridgers2013@gmail.com>
References: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, Vince Bridgers <vbridger@altera.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45523 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbaDXWCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:02:42 -0400
Received: by mail-pa0-f47.google.com with SMTP id lj1so2372474pab.6
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:02:42 -0700 (PDT)
In-Reply-To: <1398376691-15265-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridger@altera.com>

This patch changes the name used by Ethtool to something more
conventional in preparation for TSE Ethtool register dump
support to be added in the near future.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_ethtool.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
index 319ca74..76133ca 100644
--- a/drivers/net/ethernet/altera/altera_tse_ethtool.c
+++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
@@ -77,7 +77,7 @@ static void tse_get_drvinfo(struct net_device *dev,
 	struct altera_tse_private *priv = netdev_priv(dev);
 	u32 rev = ioread32(&priv->mac_dev->megacore_revision);
 
-	strcpy(info->driver, "Altera TSE MAC IP Driver");
+	strcpy(info->driver, "altera_tse");
 	strcpy(info->version, "v8.0");
 	snprintf(info->fw_version, ETHTOOL_FWVERS_LEN, "v%d.%d",
 		 rev & 0xFFFF, (rev & 0xFFFF0000) >> 16);
@@ -185,6 +185,12 @@ static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	 * how to do any special formatting of this data.
 	 * This version number will need to change if and
 	 * when this register table is changed.
+	 *
+	 * version[31:0] = 1: Dump the first 128 TSE Registers
+	 *      Upper bits are all 0 by default
+	 *
+	 * Upper 16-bits will indicate feature presence for
+	 * Ethtool register decoding in future version.
 	 */
 
 	regs->version = 1;
-- 
1.7.9.5
