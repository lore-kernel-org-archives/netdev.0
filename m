From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 1/2] Interface group: core (netlink) part
Date: Tue, 16 Oct 2007 10:01:41 +0200
Message-ID: <1824b3d462b1d85aaf33941cf082c4e018d5bff7.1192460167.git.panther__20113.8022392572$1192521788$gmane$org@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1192521703479-git-send-email-panther@balabit.hu>
Message-Id: <1824b3d462b1d85aaf33941cf082c4e018d5bff7.1192460167.git.panther@balabit.hu>
In-Reply-To: <ifgroup.20071015.1192520046.panther@balabit.hu>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Interface groups let handle different interfaces with one (netfilter) rule.
 Modified net device structure and netlink interface.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/linux/if_link.h   |    2 ++
 include/linux/netdevice.h |    2 ++
 net/core/rtnetlink.c      |    8 ++++++++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 422084d..d9f1726 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,8 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_IFGROUP,
+#define IFLA_IFGROUP IFLA_IFGROUP
 	__IFLA_MAX
 };
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e679b27..4cfc697 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -365,6 +365,8 @@ struct net_device
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
+	/* interface group this interface belongs to */
+	int			ifgroup;
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4756d58..18ff3c5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -646,6 +646,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
+	if (dev->ifgroup)
+		NLA_PUT_U32(skb, IFLA_IFGROUP, dev->ifgroup);
+
 	if (dev->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
 
@@ -846,6 +849,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		write_unlock_bh(&dev_base_lock);
 	}
 
+	if (tb[IFLA_IFGROUP]) {
+		dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP ]);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
+	}
+
 	err = 0;
 
 errout:
-- 
1.5.2.5

