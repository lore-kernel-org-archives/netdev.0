From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 09/11] net/mlx4_core: Replace sscanf() with kstrtoint()
Date: Thu, 20 Jun 2013 22:40:20 +0300
Message-ID: <1371757222-21412-10-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dotan Barak <dotanb@dev.mellanox.com>,
	Vladimir Sokolovsky <vlad@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38517 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030278Ab3FTTkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:41 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.com>

It is not safe to use sscanf.

Signed-off-by: Dotan Barak <dotanb@dev.mellanox.com>
Signed-off-by: Vladimir Sokolovsky <vlad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

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
1.8.3.251.g1462b67
