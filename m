From: Todd Broch <tbroch@chromium.org>
Subject: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Thu, 29 Dec 2011 10:33:14 -0800
Message-ID: <1325183594-8947-1-git-send-email-tbroch@chromium.org>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Todd Broch <tbroch@chromium.org>
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:55919 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751221Ab1L2Sd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 13:33:58 -0500
Received: by obcwo16 with SMTP id wo16so9483556obc.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 10:33:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The r8169 driver supports power management and correctly transitions
from active to suspend when link transitions from connected to
disconnected.  However, if link is not connected at boot the device
remains active after the initial probe.

This change adds a check of the link status to the idle pm_op that
will schedule a suspend if inactive.

Signed-off-by: Todd Broch <tbroch@chromium.org>
---
 drivers/net/ethernet/realtek/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 67bf078..3dbb5fd 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6137,6 +6137,7 @@ static int rtl8169_runtime_idle(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	__rtl8169_check_link_status(dev, tp, tp->mmio_addr, true);
 	return tp->TxDescArray ? -EBUSY : 0;
 }
 
-- 
1.7.3.1
