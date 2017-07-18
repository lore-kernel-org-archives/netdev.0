From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 22/22] mlxsw: spectrum_router: Update prefix count for IPv6
Date: Tue, 18 Jul 2017 10:10:30 +0200
Message-ID: <20170718081030.2781-23-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33103 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751547AbdGRILH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:11:07 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so1462731wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:11:06 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The number of possible prefix lengths for IPv6 is 129 and not 128.

Fixes following warning from UBSAN when /128 routes are offloaded:

 UBSAN: Undefined behaviour in
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:2510:27 index 128 is out
of range for type 'long unsigned int [128]'

Fixes: 5e9c16cc83a7 ("mlxsw: spectrum_router: Implement private fib")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 32ed2b6..e6d629f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -307,7 +307,7 @@ static struct mlxsw_sp_rif *
 mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 			 const struct net_device *dev);
 
-#define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE)
+#define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE + 1)
 
 struct mlxsw_sp_prefix_usage {
 	DECLARE_BITMAP(b, MLXSW_SP_PREFIX_COUNT);
-- 
2.9.3
