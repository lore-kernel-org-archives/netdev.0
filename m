From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 08/10] net/mlx4_core: Replace sscanf() with kstrtoint()
Date: Tue, 25 Jun 2013 12:09:36 +0300
Message-ID: <1372151378-21468-9-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Dotan Barak <dotanb@dev.mellanox.com>,
	Vladimir Sokolovsky <vlad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52114 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751515Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

It is not safe to use sscanf.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Vladimir Sokolovsky <vlad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2f4a260..81e4529 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -839,11 +839,11 @@ static ssize_t set_port_ib_mtu(struct device *dev,
 		return -EINVAL;
 	}
 
-	err = sscanf(buf, "%d", &mtu);
-	if (err > 0)
+	err = kstrtoint(buf, 0, &mtu);
+	if (!err)
 		ibta_mtu = int_to_ibta_mtu(mtu);
 
-	if (err <= 0 || ibta_mtu < 0) {
+	if (err || ibta_mtu < 0) {
 		mlx4_err(mdev, "%s is invalid IBTA mtu\n", buf);
 		return -EINVAL;
 	}
-- 
1.7.1
