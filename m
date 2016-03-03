From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V1 06/10] net/mlx5e: Relax ndo_setup_tc handle restriction
Date: Thu,  3 Mar 2016 11:23:22 +0200
Message-ID: <1456997006-18538-7-git-send-email-amir@vadai.me>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35179 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757203AbcCCJTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:19:50 -0500
Received: by mail-wm0-f65.google.com with SMTP id 1so3024977wmg.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:19:49 -0800 (PST)
In-Reply-To: <1456997006-18538-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restricting handle to TC_H_ROOT breaks the old instantiation of mqprio
to setup a hardware qdisc. This patch relaxes the test, to only check the
type.

Fixes: 08fb1da ("net/mlx5e: Support DCBNL IEEE ETS")
Signed-off-by: Amir Vadai <amir@vadai.me>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5063c0e..5e3692f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1883,7 +1883,7 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 			      __be16 proto, struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	return mlx5e_setup_tc(dev, tc->tc);
-- 
2.7.0
