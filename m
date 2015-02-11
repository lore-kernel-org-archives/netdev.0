From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net] net/mlx5_core: Fix configuration of log_uar_page_sz
Date: Wed, 11 Feb 2015 16:40:38 +0200
Message-ID: <20150211144038.GA18543@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, clsoto@us.ibm.com, ogerlitz@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34385 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbbBKOkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 09:40:43 -0500
Received: by mail-wi0-f176.google.com with SMTP id h11so4245758wiw.3
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 06:40:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code failed to configure the page size for architectures with page
size different than 4K - PPC for example.

Signed-off-by: Carol L Soto <clsoto@us.ibm.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---

Hi Dave,

this patch fixes a problem in powerpc with 64K page size

Eli

 drivers/net/ethernet/mellanox/mlx5/core/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 3a85904932e7..52d3afd6d548 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -290,6 +290,7 @@ static void copy_rw_fields(void *to, struct mlx5_caps *from)
 	MLX5_SET(cmd_hca_cap, to, log_max_ra_req_dc, from->gen.log_max_ra_req_dc);
 	MLX5_SET(cmd_hca_cap, to, log_max_ra_res_dc, from->gen.log_max_ra_res_dc);
 	MLX5_SET(cmd_hca_cap, to, pkey_table_size, to_fw_pkey_sz(from->gen.pkey_table_size));
+	MLX5_SET(cmd_hca_cap, to, log_uar_page_sz, PAGE_SHIFT - 12);
 	v64 = from->gen.flags & MLX5_CAP_BITS_RW_MASK;
 	*flags_off = cpu_to_be64(v64);
 }
-- 
2.3.0
