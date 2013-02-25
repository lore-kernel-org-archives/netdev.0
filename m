From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] net: remove the unnecessary list_del
Date: Mon, 25 Feb 2013 12:41:56 +0800
Message-ID: <1361767316-28583-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:5234 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759714Ab3BYEmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2013 23:42:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These lists are used by unregister_netdevice_many,
they are local variables,will not be seen by others.
there is no need to delete them.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/macvlan.c | 1 -
 net/core/dev.c        | 1 -
 net/core/rtnetlink.c  | 1 -
 net/mac80211/iface.c  | 1 -
 4 files changed, 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index defcd8a..9b728f1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -945,7 +945,6 @@ static int macvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, &list_kill);
 		unregister_netdevice_many(&list_kill);
-		list_del(&list_kill);
 		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid underlaying device to change its type. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 18d8b5a..7c5e9d2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6172,7 +6172,6 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 		}
 	}
 	unregister_netdevice_many(&dev_kill_list);
-	list_del(&dev_kill_list);
 	rtnl_unlock();
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d8aa20f..8e35210 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1613,7 +1613,6 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	ops->dellink(dev, &list_kill);
 	unregister_netdevice_many(&list_kill);
-	list_del(&list_kill);
 	return 0;
 }
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 2c059e5..a799629 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1639,7 +1639,6 @@ void ieee80211_remove_interfaces(struct ieee80211_local *local)
 	}
 	mutex_unlock(&local->iflist_mtx);
 	unregister_netdevice_many(&unreg_list);
-	list_del(&unreg_list);
 
 	list_for_each_entry_safe(sdata, tmp, &wdev_list, list) {
 		list_del(&sdata->list);
-- 
1.7.11.7
