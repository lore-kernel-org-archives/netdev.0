From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 14/22] e1000: always turn on receives on esb2
Date: Fri, 08 Dec 2006 15:03:16 -0800
Message-ID: <20061208230316.30109.64868.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4390 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761257AbWLHWxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:53:08 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In rare occasions, esb2 systems would end up started without the RX
unit being turned on. Add a check that runs post-init to make sure.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 12f9f61..67fc379 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2673,6 +2673,13 @@ e1000_watchdog(unsigned long data)
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



---
Auke Kok <auke-jan.h.kok@intel.com>
