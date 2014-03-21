From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 1/3] Altera TSE: Set version number by driver's get regs
Date: Thu, 20 Mar 2014 20:43:15 -0500
Message-ID: <1395366197-9781-2-git-send-email-vbridgers2013@gmail.com>
References: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36116 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759465AbaCUBsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:48:01 -0400
Received: by mail-ob0-f174.google.com with SMTP id wo20so1833134obc.5
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 18:48:01 -0700 (PDT)
In-Reply-To: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the version number returned by the driver's get regs routine
invoked by ethtool so formatting can be dependent on the version
number returned, and any interesting formatted output can check
the version number for specific types of register data returned.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_ethtool.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse_ethtool.c b/drivers/net/ethernet/altera/altera_tse_ethtool.c
index 63ac5f4..319ca74 100644
--- a/drivers/net/ethernet/altera/altera_tse_ethtool.c
+++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
@@ -181,6 +181,14 @@ static void tse_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	u32 *tse_mac_regs = (u32 *)priv->mac_dev;
 	u32 *buf = regbuf;
 
+	/* Set version to a known value, so ethtool knows
+	 * how to do any special formatting of this data.
+	 * This version number will need to change if and
+	 * when this register table is changed.
+	 */
+
+	regs->version = 1;
+
 	for (i = 0; i < TSE_NUM_REGS; i++)
 		buf[i] = ioread32(&tse_mac_regs[i]);
 }
-- 
1.7.9.5
