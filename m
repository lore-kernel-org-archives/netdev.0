From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net PATCH 1/1] qlge: Fix vlan netdev features.
Date: Tue, 14 Jan 2014 13:57:25 -0500
Message-ID: <1389725845-27469-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:61099 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751991AbaANTbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 14:31:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

vlan gets the same netdev features except vlan filter.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 449f506..f705aee 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -4765,6 +4765,8 @@ static int qlge_probe(struct pci_dev *pdev,
 			    NETIF_F_RXCSUM;
 	ndev->features = ndev->hw_features;
 	ndev->vlan_features = ndev->hw_features;
+	/* vlan gets same features (except vlan filter) */
+	ndev->vlan_features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	if (test_bit(QL_DMA64, &qdev->flags))
 		ndev->features |= NETIF_F_HIGHDMA;
-- 
1.7.6.rc1.1.g2c162b
