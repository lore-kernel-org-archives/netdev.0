From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 14/14] e1000: No-delay link detection at interface up
Date: Fri, 15 Dec 2006 10:42:34 +0100
Message-ID: <1166175754.3365.137.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751501AbWLOKBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:01:01 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9h5mQ006201
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:43:06 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9h5hR006200
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:43:05 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: No-delay link detection at interface up
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Currently after an interface up, the link state is detected 2 seconds later
when the first watchdog timer runs. This patch changes that by triggering
the hardware to generate a link-change interrupt from the up() function
instead. This has the result that the link state gets detected immediately
and without races. This has the potential to speed up booting since a normal
distribution boot process waits for a link before DHCP is attempted.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -543,7 +543,8 @@ e1000_up(struct e1000_adapter *adapter)
 
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	/* fire a link change interrupt to start the watchdog */
+	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
 	return 0;
 }
 

