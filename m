From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: i2c: Fix buffer increment counter for write transaction
Date: Wed,  1 Nov 2017 12:10:42 +0100
Message-ID: <20171101111042.8040-1-jiri@resnulli.us>
Cc: davem@davemloft.net, vadimp@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56416 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751482AbdKALKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 07:10:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id z3so4158262wme.5
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 04:10:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Pasternak <vadimp@mellanox.com>

It fixes a problem for the last chunk where 'chunk_size' is smaller than
MLXSW_I2C_BLK_MAX and data is copied to the wrong offset, overriding
previous data.

Fixes: 6882b0aee180 ("mlxsw: Introduce support for I2C bus")
Signed-off-by: Vadim Pasternak <vadimp@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/i2c.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/i2c.c b/drivers/net/ethernet/mellanox/mlxsw/i2c.c
index 12c3a44..c0dcfa0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/i2c.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/i2c.c
@@ -294,7 +294,7 @@ mlxsw_i2c_write(struct device *dev, size_t in_mbox_size, u8 *in_mbox, int num,
 		write_tran.len = MLXSW_I2C_ADDR_WIDTH + chunk_size;
 		mlxsw_i2c_set_slave_addr(tran_buf, off);
 		memcpy(&tran_buf[MLXSW_I2C_ADDR_BUF_SIZE], in_mbox +
-		       chunk_size * i, chunk_size);
+		       MLXSW_I2C_BLK_MAX * i, chunk_size);
 
 		j = 0;
 		end = jiffies + timeout;
-- 
2.9.5
