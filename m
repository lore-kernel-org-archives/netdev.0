From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net] net/mlx4: need to call close fw if alloc icm is called twice
Date: Mon,  1 Jun 2015 09:41:43 -0500
Message-ID: <1433169704-32307-2-git-send-email-clsoto@linux.vnet.ibm.com>
References: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, jackm@mellanox.com,
	brking@linux.vnet.ibm.com, clsoto@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:40717 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbbFAOqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:46:36 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Mon, 1 Jun 2015 11:46:35 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id CC3B63520068
	for <netdev@vger.kernel.org>; Mon,  1 Jun 2015 10:45:28 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t51EjGb338600896
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2015 11:45:16 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t51EkUUq000787
	for <netdev@vger.kernel.org>; Mon, 1 Jun 2015 11:46:31 -0300
In-Reply-To: <1433169704-32307-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If mlx4_enable_sriov is called by adapter without this
feature MLX4_DEV_CAP_FLAG2_SYS_EQS then during this
path the function alloc icm is called twice without 
freeing the structures from the first time.

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2837,6 +2837,7 @@ slave_start:
 								  existing_vfs,
 								  reset_flow);
 
+				mlx4_close_fw(dev);
 				mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 				dev->flags = dev_flags;
 				if (!SRIOV_VALID_STATE(dev->flags)) {
