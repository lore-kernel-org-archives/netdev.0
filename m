From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4_core: destroy workqueue when driver fails to register
Date: Tue,  3 Dec 2013 10:04:10 +0800
Message-ID: <1386036250-8485-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Wei Yang <weiyang@linux.vnet.ibm.com>
To: davem@davemloft.net, amirv@mellanox.com, jackm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:48890 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab3LCCET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 21:04:19 -0500
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 3 Dec 2013 07:34:17 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 27597394003F
	for <netdev@vger.kernel.org>; Tue,  3 Dec 2013 07:34:13 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB324A6i37879974
	for <netdev@vger.kernel.org>; Tue, 3 Dec 2013 07:34:10 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB324Bq5014791
	for <netdev@vger.kernel.org>; Tue, 3 Dec 2013 07:34:12 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver registration fails, we need to clean up the resources allocated
before. mlx4_core missed destroying the workqueue allocated.

This patch destroys the workqueue when registration fails.

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
