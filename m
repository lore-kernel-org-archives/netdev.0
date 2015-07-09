From: Jan Blunck <jblunck@infradead.org>
Subject: [PATCH] team: set IFF_SLAVE on team ports
Date: Thu,  9 Jul 2015 11:58:34 +0200
Message-ID: <1436435914-8903-1-git-send-email-jblunck@infradead.org>
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code in net/ipv6/addrconf.c:addrconf_notify() tests for IFF_SLAVE to
decide if it should start the address configuration. Since team ports
shouldn't get link-local addresses assigned lets set IFF_SLAVE when linking
a port to the team master.

Signed-off-by: Jan Blunck <jblunck@infradead.org>
---
 drivers/net/team/team.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index daa054b..4cd02c8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1086,6 +1086,7 @@ static int team_upper_dev_link(struct net_device *dev,
 	err = netdev_master_upper_dev_link(port_dev, dev);
 	if (err)
 		return err;
+	port_dev->flags |= IFF_SLAVE;
 	port_dev->priv_flags |= IFF_TEAM_PORT;
 	return 0;
 }
@@ -1094,6 +1095,7 @@ static void team_upper_dev_unlink(struct net_device *dev,
 				  struct net_device *port_dev)
 {
 	netdev_upper_dev_unlink(port_dev, dev);
+	port_dev->flags &= ~IFF_SLAVE;
 	port_dev->priv_flags &= ~IFF_TEAM_PORT;
 }
 
-- 
2.1.4
