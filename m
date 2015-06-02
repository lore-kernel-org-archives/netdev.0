From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next 2/3] net/mlx4_core: need to call close fw if alloc icm is called twice
Date: Tue,  2 Jun 2015 16:07:24 -0500
Message-ID: <1433279245-5577-2-git-send-email-clsoto@linux.vnet.ibm.com>
References: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, Carol Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:58818 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbFBVLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:11:51 -0400
Received: from /spool/local
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Tue, 2 Jun 2015 18:11:49 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id EA9483520077
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2015 17:10:42 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t52LC6KC4874366
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2015 18:12:06 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t52LBjQI001119
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2015 18:11:46 -0300
In-Reply-To: <1433279245-5577-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol Soto <clsoto@linux.vnet.ibm.com>

If mlx4_enable_sriov is called by adapter without this
feature MLX4_DEV_CAP_FLAG2_SYS_EQS then during this path the function alloc
icm is called twice without freeing the structures from the first time.

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 9485cbe..7d57777 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2976,6 +2976,7 @@ slave_start:
 								  existing_vfs,
 								  reset_flow);
 
+				mlx4_close_fw(dev);
 				mlx4_cmd_cleanup(dev, MLX4_CMD_CLEANUP_ALL);
 				dev->flags = dev_flags;
 				if (!SRIOV_VALID_STATE(dev->flags)) {
-- 
1.8.3.1
