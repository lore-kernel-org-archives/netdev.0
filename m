From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: remove some useless list_del()
Date: Tue,  3 Jun 2014 17:11:55 -0700
Message-ID: <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:33604 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815AbaFDAMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 20:12:18 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so6200610pbc.0
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 17:12:17 -0700 (PDT)
In-Reply-To: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"list_kill" is allocated on stack and it's a list head,
it is pointless to call list_del(&kill_list) especially
after unregister_netdevice_many().

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/macvlan.c | 1 -
 net/core/rtnetlink.c  | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index eee9106..cd80245 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1204,7 +1204,6 @@ static int macvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, &list_kill);
 		unregister_netdevice_many(&list_kill);
-		list_del(&list_kill);
 		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f31268d..4a1cff6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1770,7 +1770,6 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ops->dellink(dev, &list_kill);
 	unregister_netdevice_many(&list_kill);
-	list_del(&list_kill);
 	return 0;
 }
 
-- 
1.8.3.1
