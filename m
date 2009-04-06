From: Jean Delvare <khali@linux-fr.org>
Subject: [PATCH] ibm_newemac: Fix dangerous struct assumption
Date: Mon, 6 Apr 2009 14:27:10 +0200
Message-ID: <20090406142710.2d091038@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org, Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:46383 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbZDFM11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 08:27:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibm_newemac driver includes code which assumes that the
work_struct which is included in every delayed_work is the first
member of that structure. This is currently the case but might change
in the future, so use to_delayed_work() instead, which doesn't make
such an assumption.

Signed-off-by: Jean Delvare <khali@linux-fr.org>
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>
---
 drivers/net/ibm_newemac/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.30-rc0.orig/drivers/net/ibm_newemac/core.c	2009-04-06 11:18:25.000000000 +0200
+++ linux-2.6.30-rc0/drivers/net/ibm_newemac/core.c	2009-04-06 13:29:29.000000000 +0200
@@ -1229,7 +1229,7 @@ static int emac_link_differs(struct emac
 static void emac_link_timer(struct work_struct *work)
 {
 	struct emac_instance *dev =
-		container_of((struct delayed_work *)work,
+		container_of(to_delayed_work(work),
 			     struct emac_instance, link_work);
 	int link_poll_interval;
 


-- 
Jean Delvare
