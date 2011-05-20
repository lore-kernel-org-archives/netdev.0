From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/2] tg3: Fix NETIF_F_LOOPBACK error
Date: Thu, 19 May 2011 18:11:03 -0700
Message-ID: <1305853864-2135-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3792 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab1ETAvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 20:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar noticed that the features cleanup in commit
0da0606f493c5cdab74bdcc96b12f4305ad94085, entitled
"tg3: Consolidate all netdev feature assignments", mistakenly sets
NETIF_F_LOOPBACK by default.  This patch corrects the error.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 012ce70..0b78c5d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -15080,6 +15080,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			features |= NETIF_F_TSO_ECN;
 	}
 
+	dev->features |= features;
+
 	/*
 	 * Add loopback capability only for a subset of devices that support
 	 * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
@@ -15090,7 +15092,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		/* Add the loopback capability */
 		features |= NETIF_F_LOOPBACK;
 
-	dev->features |= features;
 	dev->hw_features |= features;
 	dev->vlan_features |= features;
 
-- 
1.7.3.4


