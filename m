From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 04/11] net/mlx4_en: Validate VLAN IDs provided in ethtool flow steering rules
Date: Wed, 30 Jan 2013 12:34:20 +0200
Message-ID: <1359542067-10760-5-git-send-email-amirv@mellanox.com>
References: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:49858 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754213Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
In-Reply-To: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

When attaching flow steering rules via Ethtool accept only valid vlans IDs e.g
in the range: [0,4095].

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 86afb5b..f33049f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -669,6 +669,10 @@ static int mlx4_en_validate_flow(struct net_device *dev,
 		    !(cmd->fs.m_ext.vlan_tci == 0 ||
 		      cmd->fs.m_ext.vlan_tci == cpu_to_be16(0xfff)))
 			return -EINVAL;
+		if (cmd->fs.m_ext.vlan_tci) {
+			if (be16_to_cpu(cmd->fs.h_ext.vlan_tci) >= VLAN_N_VID)
+				return -EINVAL;
+		}
 	}
 
 	return 0;
-- 
1.7.8.2
