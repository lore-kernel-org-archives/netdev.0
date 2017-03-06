From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net] team: use ETH_MAX_MTU as max mtu
Date: Mon,  6 Mar 2017 08:48:58 -0500
Message-ID: <20170306134858.2096-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This restores the ability to set a team device's mtu to anything higher
than 1500. Similar to the reported issue with bonding, the team driver
calls ether_setup(), which sets an initial max_mtu of 1500, while the
underlying hardware can handle something much larger. Just set it to
ETH_MAX_MTU to support all possible values, and the limitations of the
underlying devices will prevent setting anything too large.

Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
CC: Cong Wang <xiyou.wangcong@gmail.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/team/team.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 4a24b5d15f5a..1b52520715ae 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2072,6 +2072,7 @@ static int team_dev_type_check_change(struct net_device *dev,
 static void team_setup(struct net_device *dev)
 {
 	ether_setup(dev);
+	dev->max_mtu = ETH_MAX_MTU;
 
 	dev->netdev_ops = &team_netdev_ops;
 	dev->ethtool_ops = &team_ethtool_ops;
-- 
2.11.0
