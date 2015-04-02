From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 08/16] net/mlx5_core: Avoid copying outbox in aysnc command completion
Date: Thu,  2 Apr 2015 17:07:26 +0300
Message-ID: <1427983654-971-9-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36726 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173AbbDBOIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:02 -0400
Received: by wizk4 with SMTP id k4so16540483wiz.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:01 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid copying to the output buffer in cmd_exec since this is done after the
command is completed. Failure to do this may cause cases where the callback
handler is called before the copy done by cmd_exec which then overwrites it.

Reported-by: Tamer Hleihel <tamerh@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 43a73d36b01d..290ae87fdef7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1236,7 +1236,8 @@ static int cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 		goto out_out;
 	}
 
-	err = mlx5_copy_from_msg(out, outb, out_size);
+	if (!callback)
+		err = mlx5_copy_from_msg(out, outb, out_size);
 
 out_out:
 	if (!callback)
-- 
2.3.1
