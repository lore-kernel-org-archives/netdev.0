From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next 2/2] mlx4_en: Only cycle port if HW timestamp config changes
Date: Tue, 17 Dec 2013 14:32:39 -0600
Message-ID: <1387312359-9476-3-git-send-email-shawn.bohrer@gmail.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:46782 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab3LQUcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:32:55 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so7266177oah.29
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 12:32:55 -0800 (PST)
In-Reply-To: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

If the hwtstamp_config matches what is currently set for the device then
simply return.  Without this change any program that tries to enable
hardware timestamps will cause the link to cycle even if hardware
timstamps were already enabled.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 9b0d515..cc6a546 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -42,6 +42,10 @@ int mlx4_en_timestamp_config(struct net_device *dev, int tx_type, int rx_filter)
 	int port_up = 0;
 	int err = 0;
 
+	if (priv->hwtstamp_config.tx_type == tx_type &&
+	    priv->hwtstamp_config.rx_filter == rx_filter)
+		return 0;
+
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
-- 
1.7.7.6
