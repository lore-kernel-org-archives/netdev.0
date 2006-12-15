From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 07/14] e1000: workaround for the ESB2 NIC RX unit issue
Date: Fri, 15 Dec 2006 10:35:43 +0100
Message-ID: <1166175343.3365.123.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751487AbWLOKA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:56 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9grjJ006161
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:53 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9grXk006160
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:53 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: workaround for the ESB2 NIC RX unit issue
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

In rare occasions, ESB2 systems would end up started without the RX
unit being turned on. Add a check that runs post-init to work around this
issue.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -2579,6 +2579,13 @@ e1000_watchdog(unsigned long data)
 			netif_wake_queue(netdev);
 			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
 			adapter->smartspeed = 0;
+		} else {
+			/* make sure the receive unit is started */
+			if (adapter->hw.mac_type == e1000_80003es2lan) {
+				struct e1000_hw *hw = &adapter->hw;
+				uint32_t rctl = E1000_READ_REG(hw, RCTL);
+				E1000_WRITE_REG(hw, RCTL, rctl | E1000_RCTL_EN);
+			}
 		}
 	} else {
 		if (netif_carrier_ok(netdev)) {

