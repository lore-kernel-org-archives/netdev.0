From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4_core: pass pci_dev_data to __mlx4_init_one
Date: Mon, 24 Mar 2014 12:42:51 +0800
Message-ID: <1395636171-17347-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: amirv@mellanox.com, jackm@dev.mellanox.co.il, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:56727 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaCXEnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 00:43:05 -0400
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 24 Mar 2014 14:43:02 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B44DE357805C
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:42:59 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2O4gj8t66060420
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:42:45 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2O4gwBS025601
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 15:42:58 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The second parameter of __mlx4_init_one() is used to identify whether the
pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
this information is missed.

This patch passes the pci_dev_data to __mlx4_init_one().

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d711158..9ffce06 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2670,7 +2670,13 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
 
 static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 {
-	int ret = __mlx4_init_one(pdev, 0);
+	int ret;
+	struct mlx4_dev	 *dev  = pci_get_drvdata(pdev);
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int               pci_dev_data;
+
+	pci_dev_data = priv->pci_dev_data;
+	ret = __mlx4_init_one(pdev, pci_dev_data);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
-- 
1.7.9.5
