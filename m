From: Florian Zumbiehl <florz@florz.de>
Subject: [PATCH 3.2-rc7] skge: restore rx multicast filter on resume and
 after config changes
Date: Sat, 31 Dec 2011 04:30:09 +0100
Message-ID: <20111231033009.GE2698@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rain.florz.de ([62.216.164.86]:43105 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751926Ab1LaDaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 22:30:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore skge hardware registers for multicast filtering to their
appropriate values after system resume and after hardware restarts
that are done when changing certain settings.

Signed-off-by: Florian Zumbiehl <florz@florz.de>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index c7b6083..dea0cb4 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2606,6 +2606,9 @@ static int skge_up(struct net_device *dev)
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
+
+	skge_set_multicast(dev);
+
 	return 0;
 
  free_tx_ring:
