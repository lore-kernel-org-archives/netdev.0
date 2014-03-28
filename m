From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net 1/4] qlge: Do not propaged vlan tag offloads to vlans
Date: Thu, 27 Mar 2014 22:14:46 -0400
Message-ID: <1395972889-32289-2-git-send-email-vyasevic@redhat.com>
References: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757135AbaC1COx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 22:14:53 -0400
In-Reply-To: <1395972889-32289-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qlge driver turns off NETIF_F_HW_CTAG_FILTER, but forgets to
turn off HW_CTAG_TX and HW_CTAG_RX on vlan devices.  With the
current settings, q-in-q will only generate a single vlan header.
Remember to mask off CTAG_TX and CTAG_RX features in vlan_features.

CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
CC: Ron Mercer <ron.mercer@qlogic.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index ce2cfdd..656c65d 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4765,7 +4765,9 @@ static int qlge_probe(struct pci_dev *pdev,
 	ndev->features = ndev->hw_features;
 	ndev->vlan_features = ndev->hw_features;
 	/* vlan gets same features (except vlan filter) */
-	ndev->vlan_features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+	ndev->vlan_features &= ~(NETIF_F_HW_VLAN_CTAG_FILTER |
+				 NETIF_F_HW_VLAN_CTAG_TX |
+				 NETIF_F_HW_VLAN_CTAG_RX);
 
 	if (test_bit(QL_DMA64, &qdev->flags))
 		ndev->features |= NETIF_F_HIGHDMA;
-- 
1.8.5.3
