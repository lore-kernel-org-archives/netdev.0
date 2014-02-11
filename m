From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH] macvlan: unregister net device when netdev_upper_dev_link() fails
Date: Tue, 11 Feb 2014 15:51:29 -0800
Message-ID: <1392162690-6647-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:55226 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbaBKXvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 18:51:44 -0500
Received: by mail-pa0-f44.google.com with SMTP id kq14so8397395pab.3
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 15:51:43 -0800 (PST)
In-Reply-To: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

rtnl_newlink() doesn't unregister it for us on failure.

Cc: Patrick McHardy <kaber@trash.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 drivers/net/macvlan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 8433de4..a5d2189 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -879,14 +879,15 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	dev->priv_flags |= IFF_MACVLAN;
 	err = netdev_upper_dev_link(lowerdev, dev);
 	if (err)
-		goto destroy_port;
-
+		goto unregister_netdev;
 
 	list_add_tail_rcu(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(lowerdev, dev);
 
 	return 0;
 
+unregister_netdev:
+	unregister_netdevice(dev);
 destroy_port:
 	port->count -= 1;
 	if (!port->count)
-- 
1.8.3.1
