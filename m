From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/12] IPv6: addrconf cleanups
Date: Tue, 02 Mar 2010 15:32:52 -0800
Message-ID: <20100302234003.479864635@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58959 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab0CBXrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:31 -0500
Content-Disposition: inline; filename=addrconf-ifdown-comment.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor stuff:
  * Use bool where appropriate
  * Reformat comments and add whitespace for clarity

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv6/addrconf.c |   57 ++++++++++++++++++++++++++++------------------------
 1 file changed, 31 insertions(+), 26 deletions(-)

--- a/net/ipv6/addrconf.c	2010-03-02 14:46:33.868952041 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:46:37.933576182 -0800
@@ -139,7 +139,7 @@ static void addrconf_leave_anycast(struc
 
 static void addrconf_bonding_change(struct net_device *dev,
 				    unsigned long event);
-static int addrconf_ifdown(struct net_device *dev, int how);
+static int addrconf_ifdown(struct net_device *dev, bool how);
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
 static void addrconf_dad_timer(unsigned long data);
@@ -2171,7 +2171,7 @@ static int inet6_addr_del(struct net *ne
 			   disable IPv6 on this interface.
 			 */
 			if (list_empty(&idev->addr_list))
-				addrconf_ifdown(idev->dev, 1);
+				addrconf_ifdown(idev->dev, true);
 			return 0;
 		}
 	}
@@ -2454,6 +2454,7 @@ static int addrconf_notify(struct notifi
 				return notifier_from_errno(-ENOMEM);
 		}
 		break;
+
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
 		if (dev->flags & IFF_SLAVE)
@@ -2483,10 +2484,9 @@ static int addrconf_notify(struct notifi
 			}
 
 			if (idev) {
-				if (idev->if_flags & IF_READY) {
+				if (idev->if_flags & IF_READY)
 					/* device is already configured. */
 					break;
-				}
 				idev->if_flags |= IF_READY;
 			}
 
@@ -2515,25 +2515,30 @@ static int addrconf_notify(struct notifi
 			addrconf_dev_config(dev);
 			break;
 		}
+
 		if (idev) {
 			if (run_pending)
 				addrconf_dad_run(idev);
 
-			/* If the MTU changed during the interface down, when the
-			   interface up, the changed MTU must be reflected in the
-			   idev as well as routers.
+			/*
+			 * If the MTU changed during the interface down,
+			 * when the interface up, the changed MTU must be
+			 * reflected in the idev as well as routers.
 			 */
-			if (idev->cnf.mtu6 != dev->mtu && dev->mtu >= IPV6_MIN_MTU) {
+			if (idev->cnf.mtu6 != dev->mtu &&
+			    dev->mtu >= IPV6_MIN_MTU) {
 				rt6_mtu_change(dev, dev->mtu);
 				idev->cnf.mtu6 = dev->mtu;
 			}
 			idev->tstamp = jiffies;
 			inet6_ifinfo_notify(RTM_NEWLINK, idev);
-			/* If the changed mtu during down is lower than IPV6_MIN_MTU
-			   stop IPv6 on this interface.
+
+			/*
+			 * If the changed mtu during down is lower than
+			 * IPV6_MIN_MTU stop IPv6 on this interface.
 			 */
 			if (dev->mtu < IPV6_MIN_MTU)
-				addrconf_ifdown(dev, event != NETDEV_DOWN);
+				addrconf_ifdown(dev, true);
 		}
 		break;
 
@@ -2550,7 +2555,10 @@ static int addrconf_notify(struct notifi
 				break;
 		}
 
-		/* MTU falled under IPV6_MIN_MTU. Stop IPv6 on this interface. */
+		/*
+		 * MTU falled under IPV6_MIN_MTU.
+		 * Stop IPv6 on this interface.
+		 */
 
 	case NETDEV_DOWN:
 	case NETDEV_UNREGISTER:
@@ -2570,6 +2578,7 @@ static int addrconf_notify(struct notifi
 				return notifier_from_errno(err);
 		}
 		break;
+
 	case NETDEV_BONDING_OLDTYPE:
 	case NETDEV_BONDING_NEWTYPE:
 		addrconf_bonding_change(dev, event);
@@ -2584,7 +2593,6 @@ static int addrconf_notify(struct notifi
  */
 static struct notifier_block ipv6_dev_notf = {
 	.notifier_call = addrconf_notify,
-	.priority = 0
 };
 
 static void addrconf_bonding_change(struct net_device *dev, unsigned long event)
@@ -2600,7 +2608,7 @@ static void addrconf_bonding_change(stru
 		ipv6_mc_unmap(idev);
 }
 
-static int addrconf_ifdown(struct net_device *dev, int how)
+static int addrconf_ifdown(struct net_device *dev, bool how)
 {
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa;
@@ -2616,8 +2624,9 @@ static int addrconf_ifdown(struct net_de
 	if (idev == NULL)
 		return -ENODEV;
 
-	/* Step 1: remove reference to ipv6 device from parent device.
-		   Do not dev_put!
+	/*
+	 * Step 1: remove reference to ipv6 device from parent device.
+	 *	   Do not dev_put!
 	 */
 	if (how) {
 		idev->dead = 1;
@@ -2632,16 +2641,15 @@ static int addrconf_ifdown(struct net_de
 
 	write_lock_bh(&idev->lock);
 
-	/* Step 3: clear flags for stateless addrconf */
+	/* Step 2: clear flags for stateless addrconf */
 	if (!how)
 		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD|IF_READY);
 
-	/* Step 4: clear address list */
 #ifdef CONFIG_IPV6_PRIVACY
 	if (how && del_timer(&idev->regen_timer))
 		in6_dev_put(idev);
 
-	/* clear tempaddr list */
+	/* Step 3: clear tempaddr list */
 	while (!list_empty(&idev->tempaddr_list)) {
 		ifa = list_first_entry(&idev->tempaddr_list,
 				       struct inet6_ifaddr, tmp_list);
@@ -2667,7 +2675,7 @@ static int addrconf_ifdown(struct net_de
 
 		/* If just doing link down, and address is permanent
 		   and not link-local, then retain it. */
-		if (how == 0 &&
+		if (!how &&
 		    (ifa->flags&IFA_F_PERMANENT) &&
 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
 			list_move_tail(&ifa->if_list, &keep_list);
@@ -2709,7 +2717,6 @@ static int addrconf_ifdown(struct net_de
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
-
 	if (how)
 		ipv6_mc_destroy_dev(idev);
 	else
@@ -2717,8 +2724,7 @@ static int addrconf_ifdown(struct net_de
 
 	idev->tstamp = jiffies;
 
-	/* Shot the device (if unregistered) */
-
+	/* Last: Shot the device (if unregistered) */
 	if (how) {
 		addrconf_sysctl_unregister(idev);
 		neigh_parms_release(&nd_tbl, idev->nd_parms);
@@ -3106,8 +3112,7 @@ static void addrconf_verify(unsigned lon
 
 	del_timer(&addr_chk_timer);
 
-	for (i=0; i < IN6_ADDR_HSIZE; i++) {
-
+	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
 restart:
 		hlist_for_each_entry_rcu(ifp, node,
 					 &inet6_addr_lst[i], addr_lst) {
@@ -4374,7 +4379,7 @@ static int __addrconf_sysctl_register(st
 	if (t == NULL)
 		goto out;
 
-	for (i=0; t->addrconf_vars[i].data; i++) {
+	for (i = 0; t->addrconf_vars[i].data; i++) {
 		t->addrconf_vars[i].data += (char*)p - (char*)&ipv6_devconf;
 		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
 		t->addrconf_vars[i].extra2 = net;

-- 

