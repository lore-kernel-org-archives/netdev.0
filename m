From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 06/11] net/mlx4_core: Fix struct mlx4_vhcr_cmd to make implicit padding explicit
Date: Tue, 27 Jan 2015 15:58:04 +0200
Message-ID: <1422367089-13419-7-git-send-email-amirv@mellanox.com>
References: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49257 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758122AbbA0N7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:59:23 -0500
In-Reply-To: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Struct mlx4_vhcr was implicitly padded by the gcc compiler on 64-bit
architectures.

This commit makes that padding explicit, to prevent issues with
changing compilers and with incompatibilities between 32-bit architecture
implicit padding and 64-bit architecture implicit padding.

This structure is used in virtualization for communication between
the Host and its Guests. The explicit padding allows 64-bit Hosts
(old and new) to continue to interoperate with 64-bit Guests (old and new).

However, without this fix, 64-bit Hosts could not interoperate with 32-bit
Guests (since these did not insert the padding dword). With this fix,
32-bit Guests will be able to interoperate with 64-bit Hosts (since
the structure offsets will be identical on both).


Reported-by: Alexander Schmidt <alexs@linux.vnet.ibm.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 096a81c..148dc09 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -196,6 +196,7 @@ struct mlx4_vhcr {
 struct mlx4_vhcr_cmd {
 	__be64 in_param;
 	__be32 in_modifier;
+	u32 reserved1;
 	__be64 out_param;
 	__be16 token;
 	u16 reserved;
-- 
1.9.3
