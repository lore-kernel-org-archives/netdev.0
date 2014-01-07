From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net/mlx4_en: fix error return code in mlx4_en_get_qp()
Date: Tue, 7 Jan 2014 16:56:07 +0800
Message-ID: <CAPgLHd9HUbNsD-rKi3CSVc6gG7TAn54mDJT2WcVu4K9kJ9PuYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: amirv@mellanox.com, ogerlitz@mellanox.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:42182 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804AbaAGI4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 03:56:08 -0500
Received: by mail-bk0-f49.google.com with SMTP id my13so139037bkb.22
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 00:56:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0.

Fixes: 837052d0ccc5 ('net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling')
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 60b927e..fad4531 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -632,8 +632,9 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 	if (err)
 		goto steer_err;
 
-	if (mlx4_en_tunnel_steer_add(priv, priv->dev->dev_addr, *qpn,
-				     &priv->tunnel_reg_id))
+	err = mlx4_en_tunnel_steer_add(priv, priv->dev->dev_addr, *qpn,
+				       &priv->tunnel_reg_id);
+	if (err)
 		goto tunnel_err;
 
 	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
