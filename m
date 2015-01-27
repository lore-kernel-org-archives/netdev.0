From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 06/10] net/mlx4_core: Fix struct mlx4_vhcr_cmd to make implicit padding explicit
Date: Tue, 27 Jan 2015 11:32:55 +0200
Message-ID: <1422351179-27284-7-git-send-email-amirv@mellanox.com>
References: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:56336 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757973AbbA0Jdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 04:33:53 -0500
In-Reply-To: <1422351179-27284-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Struct mlx4_vhcr was implicitly padded by the gcc compiler.
This commit makes that padding explicit, to prevent issues with
changing compilers. Note that we added the padding dword (rather
than simply packing the structure) in order to maintain compatibility
with previous kernels.


Reported-by: Alexander Schmidt <alexs@linux.vnet.ibm.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 096a81c..595e18a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -196,13 +196,14 @@ struct mlx4_vhcr {
 struct mlx4_vhcr_cmd {
 	__be64 in_param;
 	__be32 in_modifier;
+	u32 reserved1;
 	__be64 out_param;
 	__be16 token;
 	u16 reserved;
 	u8 status;
 	u8 flags;
 	__be16 opcode;
-};
+} __packed;
 
 struct mlx4_cmd_info {
 	u16 opcode;
-- 
1.9.3
