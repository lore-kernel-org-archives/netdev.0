From: akpm@linux-foundation.org
Subject: [patch 16/21] netdev: ehea: locking order correction
Date: Fri, 28 Mar 2008 14:41:27 -0700
Message-ID: <200803282141.m2SLfRhN011846@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dwalker@mvista.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48443 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756954AbYC1Vsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>

Nested locks always need to be taken in the same order.  This change factors
out the ehea_fw_handles.lock to make the locking order consistent.

Signed-off-by: Daniel Walker <dwalker@mvista.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Christoph Raisch <raisch@de.ibm.com>
Cc: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/ehea/ehea_main.c~net-ehea-locking-order-correction drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~net-ehea-locking-order-correction
+++ a/drivers/net/ehea/ehea_main.c
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
_
