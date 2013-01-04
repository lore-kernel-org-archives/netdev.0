From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next V6 14/15] net: remove no longer used netdev_set_bond_master() and netdev_set_master()
Date: Fri,  4 Jan 2013 09:49:02 +0100
Message-ID: <1357289343-817-15-git-send-email-jiri@resnulli.us>
References: <1357289343-817-1-git-send-email-jiri@resnulli.us>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
	shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1357289343-817-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 include/linux/netdevice.h |  6 +----
 net/core/dev.c            | 63 -----------------------------------------------
 2 files changed, 1 insertion(+), 68 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 52d1146..c3723ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -856,8 +856,7 @@ struct netdev_fcoe_hbainfo {
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
  *	Return the filter ID on success, or a negative error code.
  *
- *	Slave management functions (for bridge, bonding, etc). User should
- *	call netdev_set_master() to set dev->master properly.
+ *	Slave management functions (for bridge, bonding, etc).
  * int (*ndo_add_slave)(struct net_device *dev, struct net_device *slave_dev);
  *	Called to make another netdev an underling.
  *
@@ -2648,9 +2647,6 @@ extern int netdev_master_upper_dev_link(struct net_device *dev,
 					struct net_device *upper_dev);
 extern void netdev_upper_dev_unlink(struct net_device *dev,
 				    struct net_device *upper_dev);
-extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
-extern int netdev_set_bond_master(struct net_device *dev,
-				  struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb);
 extern struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3cd8424..ba50a17 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4826,69 +4826,6 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-/**
- *	netdev_set_master	-	set up master pointer
- *	@slave: slave device
- *	@master: new master device
- *
- *	Changes the master device of the slave. Pass %NULL to break the
- *	bonding. The caller must hold the RTNL semaphore. On a failure
- *	a negative errno code is returned. On success the reference counts
- *	are adjusted and the function returns zero.
- */
-int netdev_set_master(struct net_device *slave, struct net_device *master)
-{
-	struct net_device *old = slave->master;
-	int err;
-
-	ASSERT_RTNL();
-
-	if (master) {
-		if (old)
-			return -EBUSY;
-		err = netdev_master_upper_dev_link(slave, master);
-		if (err)
-			return err;
-	}
-
-	slave->master = master;
-
-	if (old)
-		netdev_upper_dev_unlink(slave, master);
-
-	return 0;
-}
-EXPORT_SYMBOL(netdev_set_master);
-
-/**
- *	netdev_set_bond_master	-	set up bonding master/slave pair
- *	@slave: slave device
- *	@master: new master device
- *
- *	Changes the master device of the slave. Pass %NULL to break the
- *	bonding. The caller must hold the RTNL semaphore. On a failure
- *	a negative errno code is returned. On success %RTM_NEWLINK is sent
- *	to the routing socket and the function returns zero.
- */
-int netdev_set_bond_master(struct net_device *slave, struct net_device *master)
-{
-	int err;
-
-	ASSERT_RTNL();
-
-	err = netdev_set_master(slave, master);
-	if (err)
-		return err;
-	if (master)
-		slave->flags |= IFF_SLAVE;
-	else
-		slave->flags &= ~IFF_SLAVE;
-
-	rtmsg_ifinfo(RTM_NEWLINK, slave, IFF_SLAVE);
-	return 0;
-}
-EXPORT_SYMBOL(netdev_set_bond_master);
-
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
