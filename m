From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 3/3] e1000e: disable broken PHY wakeup for ICH10 LOMs, use MAC wakeup instead
Date: Wed,  2 Mar 2011 03:45:41 -0800
Message-ID: <1299066341-13820-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, <stable@kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43095 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756749Ab1CBLqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 06:46:45 -0500
In-Reply-To: <1299066341-13820-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When support for 82577/82578 was added[1] in 2.6.31, PHY wakeup was in-
advertently enabled (even though it does not function properly) on ICH10
LOMs.  This patch makes it so that the ICH10 LOMs use MAC wakeup instead
as was done with the initial support for those devices (i.e. 82567LM-3,
82567LF-3 and 82567V-4).

[1] commit a4f58f5455ba0efda36fb33c37074922d1527a10

Reported-by: Aurelien Jarno <aurelien@aurel32.net>
Cc: <stable@kernel.org>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3fa110d..2e50228 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5967,7 +5967,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		/* APME bit in EEPROM is mapped to WUC.APME */
 		eeprom_data = er32(WUC);
 		eeprom_apme_mask = E1000_WUC_APME;
-		if (eeprom_data & E1000_WUC_PHY_WAKE)
+		if ((hw->mac.type > e1000_ich10lan) &&
+		    (eeprom_data & E1000_WUC_PHY_WAKE))
 			adapter->flags2 |= FLAG2_HAS_PHY_WAKEUP;
 	} else if (adapter->flags & FLAG_APME_IN_CTRL3) {
 		if (adapter->flags & FLAG_APME_CHECK_PORT_B &&
-- 
1.7.4

