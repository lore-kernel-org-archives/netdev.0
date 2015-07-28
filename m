From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: Hardware accelerated 802.1ad works only on the first port
Date: Tue, 28 Jul 2015 13:19:19 +0300
Message-ID: <1438078759-21477-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51910 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932424AbbG1KUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 06:20:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix mistakenly used, hard coded, port number in get_phv_bit()

Fixes: 77fc29c ("net/mlx4_core: Preparations for 802.1ad VLAN support")
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Hi Dave,

Because of my mistake I've sent a version [1] without some internal review
fixes.  This patch fix the only code issue that was missing. The rest were only
improvements to the commit messages, which unfortunately it is too late to fix now.

[1] - http://www.spinics.net/lists/netdev/msg337148.html

Thanks,
Amir


 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 5a1c3d2..e8ec1de 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2815,7 +2815,7 @@ int get_phv_bit(struct mlx4_dev *dev, u8 port, int *phv)
 	struct mlx4_func_cap func_cap;
 
 	memset(&func_cap, 0, sizeof(func_cap));
-	err = mlx4_QUERY_FUNC_CAP(dev, 1, &func_cap);
+	err = mlx4_QUERY_FUNC_CAP(dev, port, &func_cap);
 	if (!err)
 		*phv = func_cap.flags & QUERY_FUNC_CAP_PHV_BIT;
 	return err;
-- 
2.4.3.413.ga5fe668
