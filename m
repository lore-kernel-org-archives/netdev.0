From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4_core: destroy workqueue when driver fails to register
Date: Mon,  2 Dec 2013 09:44:44 +0800
Message-ID: <1385948684-7284-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: davem@davemloft.net, amirv@mellanox.com, jackm@dev.mellanox.co.il,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:54922 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab3LBBo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 20:44:56 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 2 Dec 2013 11:44:53 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 54DF32BB0055
	for <netdev@vger.kernel.org>; Mon,  2 Dec 2013 12:44:49 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB21iam810682724
	for <netdev@vger.kernel.org>; Mon, 2 Dec 2013 12:44:37 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB21imkI029405
	for <netdev@vger.kernel.org>; Mon, 2 Dec 2013 12:44:48 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver registration fails, we need to clean up the resources allocated
before. mlx4_core missed to destroy the workqueue allocated.

This patch destroies the workqueue when registration fails.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5789ea2..01fc651 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2635,6 +2635,8 @@ static int __init mlx4_init(void)
 		return -ENOMEM;
 
 	ret = pci_register_driver(&mlx4_driver);
+	if (ret < 0)
+		destroy_workqueue(mlx4_wq);
 	return ret < 0 ? ret : 0;
 }
 
-- 
1.7.5.4
