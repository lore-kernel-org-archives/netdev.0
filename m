From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH RFC 2/2] net/mlx5e: Add support for ethtool get actual speed callback
Date: Wed,  2 Nov 2016 17:35:14 +0200
Message-ID: <1478100914-23610-3-git-send-email-galp@mellanox.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Cc: David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47730 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755795AbcKBPgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:36:48 -0400
In-Reply-To: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool DEVNAME will now show actual port speed in addition
to physical port speed.

Signed-off-by: Gal Pressman <galp@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 27ff401..933b687 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1504,9 +1504,16 @@ static int mlx5e_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return err;
 }
 
+static int mlx5e_get_actual_speed(struct net_device *netdev)
+{
+	/* TODO: FW command to query the actual speed */
+	return SPEED_25000;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
+	.get_actual_speed  = mlx5e_get_actual_speed,
 	.get_strings       = mlx5e_get_strings,
 	.get_sset_count    = mlx5e_get_sset_count,
 	.get_ethtool_stats = mlx5e_get_ethtool_stats,
-- 
2.7.4
