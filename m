From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next] net/mlx5_core: Set log_uar_page_sz for non 4K page size architecture
Date: Wed,  5 Aug 2015 11:05:32 -0500
Message-ID: <1438790732-29819-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
	eli@mellanox.com, amirv@mellanox.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:34835 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbbHEQKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 12:10:04 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Wed, 5 Aug 2015 13:10:01 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 29F461DC006D
	for <netdev@vger.kernel.org>; Wed,  5 Aug 2015 12:08:58 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t75GAMO74808888
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2015 13:10:22 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t75G9wum017342
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2015 13:09:58 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

failed to configure the page size for architectures with page size
different than 4K.

Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 603a8b0..03aabdd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -391,6 +391,8 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 	/* disable cmdif checksum */
 	MLX5_SET(cmd_hca_cap, set_hca_cap, cmdif_checksum, 0);
 
+	MLX5_SET(cmd_hca_cap, set_hca_cap, log_uar_page_sz, PAGE_SHIFT - 12);
+
 	err = set_caps(dev, set_ctx, set_sz);
 
 query_ex:
-- 
1.8.3.1
