From: fgao@ikuai8.com
Subject: [PATCH net 1/1] driver: ipvlan: Unlink the upper dev when ipvlan_link_new failed
Date: Thu,  8 Dec 2016 09:21:00 +0800
Message-ID: <1481160060-28730-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg340.qq.com ([14.17.44.35]:33770 "EHLO smtpbg340.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932682AbcLHBVx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 20:21:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When netdev_upper_dev_unlink failed in ipvlan_link_new, need to
unlink the ipvlan dev with upper dev.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 0fef178..189adbc 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -546,13 +546,15 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	}
 	err = ipvlan_set_port_mode(port, mode);
 	if (err) {
-		goto unregister_netdev;
+		goto dev_unlink;
 	}
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
 	netif_stacked_transfer_operstate(phy_dev, dev);
 	return 0;
 
+dev_unlink:
+	netdev_upper_dev_unlink(phy_dev, dev);
 unregister_netdev:
 	unregister_netdevice(dev);
 destroy_ipvlan_port:
-- 
1.9.1
