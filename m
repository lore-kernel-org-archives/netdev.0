From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: fix sleeping while holding spinlock.
Date: Tue, 9 Nov 2010 00:23:58 +0100
Message-ID: <20101108232358.GB13720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 254.185.140-88.rev.gaoland.net ([88.140.185.254]:60180 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754165Ab0KHX3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 18:29:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As device_set_wakeup_enable can now sleep, move the call to outside
the critical section.

Signed-off-by: Daniel J Blueman <daniel.blueman@gmail.com>
Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3a0877e..4c4d169 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -846,10 +846,10 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	else
 		tp->features &= ~RTL_FEATURE_WOL;
 	__rtl8169_set_wol(tp, wol->wolopts);
-	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
-
 	spin_unlock_irq(&tp->lock);
 
+	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
+
 	return 0;
 }
 
-- 
1.7.2.3

