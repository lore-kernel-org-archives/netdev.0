From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 08/14]  e1000: fix to set the new max frame size before
	resetting the adapter
Date: Fri, 15 Dec 2006 10:36:35 +0100
Message-ID: <1166175395.3365.125.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751409AbWLOKAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:53 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gtPg006168
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:55 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9gt2t006167
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:55 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: fix to set the new max frame size before resetting the adapter
From: Bruce Allan <bruce.w.allan@intel.com>

This bugfix makes sure that the driver data reflects the full new situation
before the adapter is reinitialized.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -3485,12 +3485,11 @@ e1000_change_mtu(struct net_device *netd
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
 	netdev->mtu = new_mtu;
+	adapter->hw.max_frame_size = max_frame;
 
 	if (netif_running(netdev))
 		e1000_reinit_locked(adapter);
 
-	adapter->hw.max_frame_size = max_frame;
-
 	return 0;
 }
 

