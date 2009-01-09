From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] 3c59x: Use device_set_wakeup_enable
Date: Fri, 9 Jan 2009 14:53:17 +0100
Message-ID: <20090109135317.GC6473@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gwilford@gmail.com, degnbol@danbbs.dk
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:37492 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbZAIOUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 09:20:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since dev->power.should_wakeup bit is used by the PCI core to
decide whether the device should wake up the system from sleep
states, set this bit by calling device_set_wakeup_enable().

This restores proper WOL for the 3c59x driver.

Reported-and-tested-by: Graeme Wilford <gwilford@gmail.com>
Reported-by: Gunnar Degnbol <degnbol@danbbs.dk>
Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
---
 drivers/net/3c59x.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 665e7fd..cdbbb62 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -3109,6 +3109,8 @@ static void acpi_set_WOL(struct net_device *dev)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 
+	device_set_wakeup_enable(vp->gendev, vp->enable_wol);
+
 	if (vp->enable_wol) {
 		/* Power up on: 1==Downloaded Filter, 2==Magic Packets, 4==Link Status. */
 		EL3WINDOW(7);
-- 
1.5.3

