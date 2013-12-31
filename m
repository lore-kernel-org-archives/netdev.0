From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next v4 2/2] mlx4_en: Only cycle port if HW timestamp config changes
Date: Tue, 31 Dec 2013 11:39:40 -0600
Message-ID: <1388511580-3657-3-git-send-email-shawn.bohrer@gmail.com>
References: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:43339 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab3LaRkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 12:40:15 -0500
Received: by mail-ob0-f169.google.com with SMTP id wm4so12937493obc.14
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 09:40:15 -0800 (PST)
In-Reply-To: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
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
index 30712b3..abaf6bb 100644
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
