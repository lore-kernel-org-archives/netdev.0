From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next v2 1/2] tg3: Fix NETIF_F_LOOPBACK error
Date: Thu, 19 May 2011 19:02:43 -0700
Message-ID: <1305856964-2291-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Mahesh Bandewar" <maheshb@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1565 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934716Ab1ETBnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 21:43:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar noticed that the features cleanup in commit
0da0606f493c5cdab74bdcc96b12f4305ad94085, entitled
"tg3: Consolidate all netdev feature assignments", mistakenly sets
NETIF_F_LOOPBACK by default.  This patch corrects the error.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/tg3.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 012ce70..284e998 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -15080,6 +15080,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			features |= NETIF_F_TSO_ECN;
 	}
 
+	dev->features |= features;
+	dev->vlan_features |= features;
+
 	/*
 	 * Add loopback capability only for a subset of devices that support
 	 * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
@@ -15090,9 +15093,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		/* Add the loopback capability */
 		features |= NETIF_F_LOOPBACK;
 
-	dev->features |= features;
 	dev->hw_features |= features;
-	dev->vlan_features |= features;
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !tg3_flag(tp, TSO_CAPABLE) &&
-- 
1.7.3.4


