From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 3/5] net: ehea: locking order correction
Date: Thu, 06 Mar 2008 00:00:03 -0800
Message-ID: <20080307031633.383493280@mvista.com>
References: <20080307031621.590778480@mvista.com>
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:63398 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757358AbYCGD0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 22:26:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Content-Disposition: inline; filename=net-ehea-correct-locking-order.patch

Nested locks always need to be taken in the same order. This change
factors out the ehea_fw_handles.lock to make the locking order
consistent.

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ehea/ehea_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.24/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea_main.c
+++ linux-2.6.24/drivers/net/ehea/ehea_main.c
@@ -2567,14 +2567,14 @@ static int ehea_down(struct net_device *
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;
 
+	mutex_lock(&ehea_fw_handles.lock);
+
 	down(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
 	ehea_free_interrupts(dev);
 
-	mutex_lock(&ehea_fw_handles.lock);
-
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();

-- 
