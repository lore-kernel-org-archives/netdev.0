From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 12/14] net/mlx5e: Fix wrong delay calculation for overflow check scheduling
Date: Thu, 27 Jul 2017 13:25:30 +0300
Message-ID: <20170727102532.2317-13-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45004 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751452AbdG0K1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:14 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

The overflow_period is calculated in seconds. In order to use it
for delayed work scheduling translation to jiffies is needed.

Fixes: ef9814deafd0 ('net/mlx5e: Add HW timestamping (TS) support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index ba355c6b6e1f..cde8e8e772ec 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -119,7 +119,8 @@ static void mlx5e_timestamp_overflow(struct work_struct *work)
 	write_lock_irqsave(&tstamp->lock, flags);
 	timecounter_read(&tstamp->clock);
 	write_unlock_irqrestore(&tstamp->lock, flags);
-	schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);
+	schedule_delayed_work(&tstamp->overflow_work,
+			      msecs_to_jiffies(tstamp->overflow_period * 1000));
 }
 
 int mlx5e_hwstamp_set(struct mlx5e_priv *priv, struct ifreq *ifr)
-- 
2.13.0
