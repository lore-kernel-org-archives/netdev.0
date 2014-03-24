From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] tg3: Do not include vlan acceleration features in vlan_features
Date: Mon, 24 Mar 2014 17:52:12 -0400
Message-ID: <1395697932-28247-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbaCXVwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 17:52:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Including hardware acceleration features in vlan_features breaks
stacked vlans (Q-in-Q) by marking the bottom vlan interface as
capable of acceleration.  This causes one of the tags to be lost
and the packets are sent with a sing vlan header.

CC: Nithin Nayak Sujir <nsujir@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3b6d0ba..70a225c8 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17649,8 +17649,6 @@ static int tg3_init_one(struct pci_dev *pdev,
 
 	tg3_init_bufmgr_config(tp);
 
-	features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
-
 	/* 5700 B0 chips do not support checksumming correctly due
 	 * to hardware bugs.
 	 */
@@ -17682,7 +17680,8 @@ static int tg3_init_one(struct pci_dev *pdev,
 			features |= NETIF_F_TSO_ECN;
 	}
 
-	dev->features |= features;
+	dev->features |= features | NETIF_F_HW_VLAN_CTAG_TX |
+			 NETIF_F_HW_VLAN_CTAG_RX;
 	dev->vlan_features |= features;
 
 	/*
-- 
1.8.5.3
