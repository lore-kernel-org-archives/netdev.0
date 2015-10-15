From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] mlx4: corretly check failed allocation
Date: Thu, 15 Oct 2015 12:24:09 -0400
Message-ID: <1444926249-29033-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	Insu Yun <wuninsu@gmail.com>
To: davem@davemloft.net, amirv@mellanox.com, maorg@mellanox.com,
	ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	yishaih@mellanox.com, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f195.google.com ([209.85.160.195]:33010 "EHLO
	mail-yk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbbJOQXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 12:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocation fails, mlx4_alloc_cmd_mailbox returns -ENOMEM.
Since there is no case that mlx4_alloc_cmd_mailbox returns NULL,
it needs to be checked by IS_ERR, not IS_ERR_OR_NULL

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/mr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 78f51e1..9319519 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -318,7 +318,7 @@ int mlx4_mr_hw_get_mpt(struct mlx4_dev *dev, struct mlx4_mr *mmr,
 				key, NULL);
 	} else {
 		mailbox = mlx4_alloc_cmd_mailbox(dev);
-		if (IS_ERR_OR_NULL(mailbox))
+		if (IS_ERR(mailbox))
 			return PTR_ERR(mailbox);
 
 		err = mlx4_cmd_box(dev, 0, mailbox->dma, key,
-- 
1.9.1
