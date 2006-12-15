From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 03/14] e1000: omit stats for broken counter in 82543
Date: Fri, 15 Dec 2006 10:31:40 +0100
Message-ID: <1166175100.3365.115.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751409AbWLOKA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:57 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9glRn006143
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:47 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9glgJ006140
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:47 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: omit stats for broken counter in 82543
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The 82543 chip does not count tx_carrier_errors properly in FD mode;
report zeros instead of garbage.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |    5 +++++
 1 file changed, 5 insertions(+), 0 deletion(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -3580,7 +3580,12 @@ e1000_update_stats(struct e1000_adapter 
 	adapter->net_stats.tx_errors = adapter->stats.txerrc;
 	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
 	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
 	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
+	if (adapter->hw.mac_type == e1000_82543 &&
+	    adapter->link_duplex == FULL_DUPLEX) {
+		adapter->net_stats.tx_carrier_errors = 0;
+		adapter->stats.tncrs = 0;
+	}
 
 	/* Tx Dropped needs to be maintained elsewhere */
 

