From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: fix a race between PCI probe and dev_open
Date: Fri, 9 Mar 2007 00:00:05 +0100
Message-ID: <20070308230005.GB27354@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>,
	Bernhard Walle <bwalle@suse.de>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43854 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030862AbXCHXF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 18:05:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initialize the timer with the rest of the private-struct.

Signed-off-by: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 15d954e..688b64d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1368,11 +1368,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
-	init_timer(timer);
-	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
-	timer->data = (unsigned long)(dev);
-	timer->function = rtl8169_phy_timer;
-	add_timer(timer);
+	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1685,6 +1681,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->mmio_addr = ioaddr;
 	tp->align = rtl_cfg_info[ent->driver_data].align;
 
+	init_timer(&tp->timer);
+	tp->timer.data = (unsigned long) dev;
+	tp->timer.function = rtl8169_phy_timer;
+
 	spin_lock_init(&tp->lock);
 
 	rc = register_netdev(dev);
-- 
1.4.4.4

