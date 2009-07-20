From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH 3/3] can: switch carrier on if device was stopped while in bus-off state
Date: Mon, 20 Jul 2009 16:06:41 +0200
Message-ID: <20090720140638.910228137@denx.de>
References: <20090720140638.342067093@denx.de>
Cc: socketcan-core@lists.berlios.de,
	Kurt Van Dijck <kurt.van.dijck@skynet.be>,
	Wolfgang Grandegger <wg@grandegger.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:45614 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822AbZGTOGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 10:06:40 -0400
Content-Disposition: inline; filename=can-bus-off-carrier.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem when a device is stopped while in the
bus-off state. Then the carrier remains off forever.

Signed-off-by: Kurt Van Dijck <kurt.van.dijck@skynet.be>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/dev.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/dev.c	2009-07-20 16:03:35.083997416 +0200
+++ net-next-2.6/drivers/net/can/dev.c	2009-07-20 16:03:35.100998431 +0200
@@ -473,6 +473,10 @@
 		return -EINVAL;
 	}
 
+	/* Switch carrier on if device was stopped while in bus-off state */
+	if (!netif_carrier_ok(dev))
+		netif_carrier_on(dev);
+
 	setup_timer(&priv->restart_timer, can_restart, (unsigned long)dev);
 
 	return 0;

