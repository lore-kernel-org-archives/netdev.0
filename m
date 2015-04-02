From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 10/16] net/mlx5_core: Fix a bug in alloc_token
Date: Thu,  2 Apr 2015 17:07:28 +0300
Message-ID: <1427983654-971-11-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33493 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbbDBOIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:06 -0400
Received: by wixm2 with SMTP id m2so56729267wix.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:05 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

In alloc_token(), the token '1' would be allocated twice consecutively.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 0d862696b876..697d538163f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -125,7 +125,10 @@ static u8 alloc_token(struct mlx5_cmd *cmd)
 	u8 token;
 
 	spin_lock(&cmd->token_lock);
-	token = cmd->token++ % 255 + 1;
+	cmd->token++;
+	if (cmd->token == 0)
+		cmd->token++;
+	token = cmd->token;
 	spin_unlock(&cmd->token_lock);
 
 	return token;
-- 
2.3.1
