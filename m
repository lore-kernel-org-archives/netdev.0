From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: switchx2: Fix misuse of hard_header_len
Date: Tue,  4 Oct 2016 09:46:05 +0200
Message-ID: <1475567165-3362-3-git-send-email-jiri@resnulli.us>
References: <1475567165-3362-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32928 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753096AbcJDHqL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 03:46:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id p138so18248771wmb.0
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 00:46:10 -0700 (PDT)
In-Reply-To: <1475567165-3362-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In order to specify that the mlxsw switchx2 driver needs additional
headroom for packets, there have been use of the hard_header_len field of
the netdevice struct.

This commit changes that to use needed_headroom instead, as this is the
correct way to do that.

Fixes: 31557f0f9755 ("mlxsw: Introduce Mellanox SwitchX-2 ASIC support")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 377daa4..b2c5721 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -997,7 +997,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	/* Each packet needs to have a Tx header (metadata) on top all other
 	 * headers.
 	 */
-	dev->hard_header_len += MLXSW_TXHDR_LEN;
+	dev->needed_headroom = MLXSW_TXHDR_LEN;
 
 	err = mlxsw_sx_port_module_check(mlxsw_sx_port, &usable);
 	if (err) {
-- 
2.5.5
