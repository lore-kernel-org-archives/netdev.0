From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next 2/2] net/mlx4_core: Fix unintialized variable used in error path
Date: Thu, 27 Aug 2015 14:43:26 -0500
Message-ID: <1440704606-20452-2-git-send-email-clsoto@linux.vnet.ibm.com>
References: <1440704606-20452-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Matan Barak <matanb@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:37119 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbbH0TsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 15:48:12 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Thu, 27 Aug 2015 16:48:11 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id D969B352009D
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 15:46:59 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7RJkTiW11468946
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 16:46:29 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7RJm07u015996
	for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 15:48:01 -0400
In-Reply-To: <1440704606-20452-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

The uninitialized value name in mlx4_en_activate_cq was used in order
to print an error message. Fixing it by replacing it with cq->vector.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 63769df..a1918e2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -100,7 +100,6 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err = 0;
-	char name[25];
 	int timestamp_en = 0;
 	bool assigned_eq = false;
 
@@ -119,8 +118,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			err = mlx4_assign_eq(mdev->dev, priv->port,
 					     &cq->vector);
 			if (err) {
-				mlx4_err(mdev, "Failed assigning an EQ to %s\n",
-					 name);
+				mlx4_err(mdev, "Failed assigning an EQ to CQ vector %d\n",
+					 cq->vector);
 				goto free_eq;
 			}
 
-- 
1.8.3.1
