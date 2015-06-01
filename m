From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net] net/mlx4: double free of dev_vfs
Date: Mon,  1 Jun 2015 09:41:42 -0500
Message-ID: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, jackm@mellanox.com,
	brking@linux.vnet.ibm.com, clsoto@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:40673 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542AbbFAOqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:46:34 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Mon, 1 Jun 2015 11:46:29 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 206DB1DC0057
	for <netdev@vger.kernel.org>; Mon,  1 Jun 2015 10:45:28 -0400 (EDT)
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t51EjCeX47054876
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2015 11:45:12 -0300
Received: from d24av03.br.ibm.com (localhost [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t51EkR5J009551
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2015 11:46:27 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If user loads mlx4_core with num_vfs greater than supported
then variable dev->dev_vfs is freed 2 times after unloading
the driver.

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2685,6 +2685,7 @@ disable_sriov:
 free_mem:
 	dev->persist->num_vfs = 0;
 	kfree(dev->dev_vfs);
+	dev->dev_vfs = NULL;
 	return dev_flags & ~MLX4_FLAG_MASTER;
 }
 
