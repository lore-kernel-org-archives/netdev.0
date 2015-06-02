From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next 1/3] net/mlx4_core: double free of dev_vfs
Date: Tue,  2 Jun 2015 16:07:23 -0500
Message-ID: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:53769 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbFBVLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:11:51 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Tue, 2 Jun 2015 18:11:49 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 484893520062
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:10:41 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t52LASm866781342
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2015 18:10:28 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t52LBhnJ001073
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2015 18:11:44 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

If user loads mlx4_core with num_vfs greater than
supported then variable dev->dev_vfs is freed 2 times after unloading the
driver.

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 0dbd704..9485cbe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2824,6 +2824,7 @@ disable_sriov:
 free_mem:
 	dev->persist->num_vfs = 0;
 	kfree(dev->dev_vfs);
+        dev->dev_vfs = NULL;
 	return dev_flags & ~MLX4_FLAG_MASTER;
 }
 
-- 
1.8.3.1
