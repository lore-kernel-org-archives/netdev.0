From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/8] e1000: FIX: move length adjustment due to crc stripping disabled.
Date: Tue, 17 Oct 2006 12:02:46 -0700
Message-ID: <20061017190246.4194.97329.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:19726 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751436AbWJQSyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:54:52 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Move the length (rx_bytes counter) adjustment of 4 bytes down to after the
TBI_ACCEPT workaround.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 95bbb2d..89ab34d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3786,9 +3786,6 @@ e1000_clean_rx_irq(struct e1000_adapter 
 
 		length = le16_to_cpu(rx_desc->length);
 
-		/* adjust length to remove Ethernet CRC */
-		length -= 4;
-
 		if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
@@ -3816,6 +3813,10 @@ e1000_clean_rx_irq(struct e1000_adapter 
 			}
 		}
 
+		/* adjust length to remove Ethernet CRC, this must be
+		 * done after the TBI_ACCEPT workaround above */
+		length -= 4;
+
 		/* code added for copybreak, this should improve
 		 * performance for small packets with large amounts
 		 * of reassembly being done in the stack */



---
Auke Kok <auke-jan.h.kok@intel.com>
