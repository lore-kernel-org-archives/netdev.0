From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/8] e1000: display flow control of link status at link up
Date: Fri, 12 Jan 2007 16:37:49 -0800
Message-ID: <20070113003749.16816.61771.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1200 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161184AbXAMAyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:11 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Print RX/TX flow control setting at link up time to display the
actual link FC properties instead of the advertised values.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ab1b40f..43dde27 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2583,15 +2583,22 @@ e1000_watchdog(unsigned long data)
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
+			uint32_t ctrl;
 			boolean_t txb2b = 1;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
 
-			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s\n",
-			       adapter->link_speed,
-			       adapter->link_duplex == FULL_DUPLEX ?
-			       "Full Duplex" : "Half Duplex");
+			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s, "
+			        "Flow Control: %s\n",
+			        adapter->link_speed,
+			        adapter->link_duplex == FULL_DUPLEX ?
+			        "Full Duplex" : "Half Duplex",
+			        ((ctrl & E1000_CTRL_TFCE) && (ctrl &
+			        E1000_CTRL_RFCE)) ? "RX/TX" : ((ctrl &
+			        E1000_CTRL_RFCE) ? "RX" : ((ctrl &
+			        E1000_CTRL_TFCE) ? "TX" : "None" )));
 
 			/* tweak tx_queue_len according to speed/duplex
 			 * and adjust the timeout factor */



---
Auke Kok <auke-jan.h.kok@intel.com>
