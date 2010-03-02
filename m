From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/12] IPv6: addrconf checkpatch fixes
Date: Tue, 02 Mar 2010 15:32:53 -0800
Message-ID: <20100302234003.552263855@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58963 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753545Ab0CBXrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:37 -0500
Content-Disposition: inline; filename=addrconf-checkpatch.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This resolves a number of checkpatch complaints.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/addrconf.c	2010-03-02 14:46:37.933576182 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:46:40.529202001 -0800
@@ -81,7 +81,7 @@
 #include <linux/random.h>
 #endif
 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <asm/unaligned.h>
 
 #include <linux/proc_fs.h>
@@ -97,7 +97,7 @@
 #endif
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
-#define TIME_DELTA(a,b) ((unsigned long)((long)(a) - (long)(b)))
+#define TIME_DELTA(a, b) ((unsigned long)((long)(a) - (long)(b)))
 
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev);
@@ -249,8 +249,7 @@ static void addrconf_del_timer(struct in
 		__in6_ifa_put(ifp);
 }
 
-enum addrconf_timer_t
-{
+enum addrconf_timer_t {
 	AC_NONE,
 	AC_DAD,
 	AC_RS,
@@ -270,7 +269,8 @@ static void addrconf_mod_timer(struct in
 	case AC_RS:
 		ifp->timer.function = addrconf_rs_timer;
 		break;
-	default:;
+	default:
+		break;
 	}
 	ifp->timer.expires = jiffies + when;
 	add_timer(&ifp->timer);
@@ -325,7 +325,7 @@ void in6_dev_finish_destroy(struct inet6
 #endif
 	dev_put(dev);
 	if (!idev->dead) {
-		printk("Freeing alive inet6 device %p\n", idev);
+		pr_warning("Freeing alive inet6 device %p\n", idev);
 		return;
 	}
 	snmp6_free_dev(idev);
@@ -441,8 +441,10 @@ static struct inet6_dev * ipv6_find_idev
 
 	ASSERT_RTNL();
 
-	if ((idev = __in6_dev_get(dev)) == NULL) {
-		if ((idev = ipv6_add_dev(dev)) == NULL)
+	idev = __in6_dev_get(dev);
+	if (!idev) {
+		idev = ipv6_add_dev(dev);
+		if (!idev)
 			return NULL;
 	}
 
@@ -544,10 +546,10 @@ void inet6_ifa_finish_destroy(struct ine
 	in6_dev_put(ifp->idev);
 
 	if (del_timer(&ifp->timer))
-		printk("Timer is still running, when freeing ifa=%p\n", ifp);
+		pr_notice("Timer is still running, when freeing ifa=%p\n", ifp);
 
 	if (!ifp->dead) {
-		printk("Freeing alive inet6 address %p\n", ifp);
+		pr_warning("Freeing alive inet6 address %p\n", ifp);
 		return;
 	}
 	dst_release(&ifp->rt->u.dst);
@@ -1225,7 +1227,6 @@ try_nextdev:
 	in6_ifa_put(hiscore->ifa);
 	return 0;
 }
-
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
 
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
@@ -1235,7 +1236,8 @@ int ipv6_get_lladdr(struct net_device *d
 	int err = -EADDRNOTAVAIL;
 
 	rcu_read_lock();
-	if ((idev = __in6_dev_get(dev)) != NULL) {
+	idev = __in6_dev_get(dev);
+	if (idev) {
 		struct inet6_ifaddr *ifp;
 
 		read_lock_bh(&idev->lock);
@@ -1723,7 +1725,8 @@ static struct inet6_dev *addrconf_add_de
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL)
+	idev = ipv6_find_idev(dev);
+	if (!idev)
 		return NULL;
 
 	/* Add default multicast route */
@@ -2431,7 +2434,8 @@ static void addrconf_ip6_tnl_config(stru
 
 	ASSERT_RTNL();
 
-	if ((idev = addrconf_add_dev(dev)) == NULL) {
+	idev = addrconf_add_dev(dev);
+	if (!idev) {
 		printk(KERN_DEBUG "init ip6-ip6: add_dev failed\n");
 		return;
 	}
@@ -2446,7 +2450,7 @@ static int addrconf_notify(struct notifi
 	int run_pending = 0;
 	int err;
 
-	switch(event) {
+	switch (event) {
 	case NETDEV_REGISTER:
 		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
 			idev = ipv6_add_dev(dev);
@@ -2498,7 +2502,7 @@ static int addrconf_notify(struct notifi
 			run_pending = 1;
 		}
 
-		switch(dev->type) {
+		switch (dev->type) {
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 		case ARPHRD_SIT:
 			addrconf_sit_config(dev);
@@ -2835,7 +2839,7 @@ static void addrconf_dad_start(struct in
 	 * Optimistic nodes can start receiving
 	 * Frames right away
 	 */
-	if(ifp->flags & IFA_F_OPTIMISTIC)
+	if (ifp->flags & IFA_F_OPTIMISTIC)
 		ip6_ins_rt(ifp->rt);
 
 	addrconf_dad_kick(ifp);
@@ -2885,7 +2889,7 @@ out:
 
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
-	struct net_device *	dev = ifp->idev->dev;
+	struct net_device *dev = ifp->idev->dev;
 
 	/*
 	 *	Configure the address for reception. Now it is valid.
@@ -2916,7 +2920,8 @@ static void addrconf_dad_completed(struc
 	}
 }
 
-static void addrconf_dad_run(struct inet6_dev *idev) {
+static void addrconf_dad_run(struct inet6_dev *idev)
+{
 	struct inet6_ifaddr *ifp;
 
 	read_lock_bh(&idev->lock);
@@ -2981,7 +2986,7 @@ static struct inet6_ifaddr *if6_get_idx(
 	struct inet6_ifaddr *ifa = if6_get_first(seq);
 
 	if (ifa)
-		while(pos && (ifa = if6_get_next(seq, ifa)) != NULL)
+		while (pos && (ifa = if6_get_next(seq, ifa)) != NULL)
 			--pos;
 	return pos ? NULL : ifa;
 }
@@ -3490,8 +3495,7 @@ static int inet6_fill_ifacaddr(struct sk
 	return nlmsg_end(skb, nlh);
 }
 
-enum addr_type_t
-{
+enum addr_type_t {
 	UNICAST_ADDR,
 	MULTICAST_ADDR,
 	ANYCAST_ADDR,
@@ -3590,7 +3594,8 @@ static int inet6_dump_addr(struct sk_buf
 			if (idx > s_idx)
 				s_ip_idx = 0;
 			ip_idx = 0;
-			if ((idev = __in6_dev_get(dev)) == NULL)
+			idev = __in6_dev_get(dev);
+			if (!idev)
 				goto cont;
 
 			if (in6_dump_addrs(idev, skb, cb, type,
@@ -3657,12 +3662,14 @@ static int inet6_rtm_getaddr(struct sk_b
 	if (ifm->ifa_index)
 		dev = __dev_get_by_index(net, ifm->ifa_index);
 
-	if ((ifa = ipv6_get_ifaddr(net, addr, dev, 1)) == NULL) {
+	ifa = ipv6_get_ifaddr(net, addr, dev, 1);
+	if (!ifa) {
 		err = -EADDRNOTAVAIL;
 		goto errout;
 	}
 
-	if ((skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_KERNEL)) == NULL) {
+	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_KERNEL);
+	if (!skb) {
 		err = -ENOBUFS;
 		goto errout_ifa;
 	}
@@ -3787,7 +3794,7 @@ static inline void __snmp6_fill_stats(u6
 static void snmp6_fill_stats(u64 *stats, struct inet6_dev *idev, int attrtype,
 			     int bytes)
 {
-	switch(attrtype) {
+	switch (attrtype) {
 	case IFLA_INET6_STATS:
 		__snmp6_fill_stats(stats, (void __percpu **)idev->stats.ipv6, IPSTATS_MIB_MAX, bytes);
 		break;
@@ -4139,211 +4146,211 @@ static struct addrconf_sysctl_table
 	.sysctl_header = NULL,
 	.addrconf_vars = {
 		{
-			.procname	=	"forwarding",
-			.data		=	&ipv6_devconf.forwarding,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	addrconf_sysctl_forward,
+			.procname	= "forwarding",
+			.data		= &ipv6_devconf.forwarding,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= addrconf_sysctl_forward,
 		},
 		{
-			.procname	=	"hop_limit",
-			.data		=	&ipv6_devconf.hop_limit,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "hop_limit",
+			.data		= &ipv6_devconf.hop_limit,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"mtu",
-			.data		=	&ipv6_devconf.mtu6,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "mtu",
+			.data		= &ipv6_devconf.mtu6,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"accept_ra",
-			.data		=	&ipv6_devconf.accept_ra,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_ra",
+			.data		= &ipv6_devconf.accept_ra,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"accept_redirects",
-			.data		=	&ipv6_devconf.accept_redirects,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_redirects",
+			.data		= &ipv6_devconf.accept_redirects,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"autoconf",
-			.data		=	&ipv6_devconf.autoconf,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "autoconf",
+			.data		= &ipv6_devconf.autoconf,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"dad_transmits",
-			.data		=	&ipv6_devconf.dad_transmits,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "dad_transmits",
+			.data		= &ipv6_devconf.dad_transmits,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"router_solicitations",
-			.data		=	&ipv6_devconf.rtr_solicits,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "router_solicitations",
+			.data		= &ipv6_devconf.rtr_solicits,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"router_solicitation_interval",
-			.data		=	&ipv6_devconf.rtr_solicit_interval,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec_jiffies,
+			.procname	= "router_solicitation_interval",
+			.data		= &ipv6_devconf.rtr_solicit_interval,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec_jiffies,
 		},
 		{
-			.procname	=	"router_solicitation_delay",
-			.data		=	&ipv6_devconf.rtr_solicit_delay,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec_jiffies,
+			.procname	= "router_solicitation_delay",
+			.data		= &ipv6_devconf.rtr_solicit_delay,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec_jiffies,
 		},
 		{
-			.procname	=	"force_mld_version",
-			.data		=	&ipv6_devconf.force_mld_version,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "force_mld_version",
+			.data		= &ipv6_devconf.force_mld_version,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_PRIVACY
 		{
-			.procname	=	"use_tempaddr",
-			.data		=	&ipv6_devconf.use_tempaddr,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "use_tempaddr",
+			.data		= &ipv6_devconf.use_tempaddr,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"temp_valid_lft",
-			.data		=	&ipv6_devconf.temp_valid_lft,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "temp_valid_lft",
+			.data		= &ipv6_devconf.temp_valid_lft,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"temp_prefered_lft",
-			.data		=	&ipv6_devconf.temp_prefered_lft,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "temp_prefered_lft",
+			.data		= &ipv6_devconf.temp_prefered_lft,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"regen_max_retry",
-			.data		=	&ipv6_devconf.regen_max_retry,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "regen_max_retry",
+			.data		= &ipv6_devconf.regen_max_retry,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"max_desync_factor",
-			.data		=	&ipv6_devconf.max_desync_factor,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "max_desync_factor",
+			.data		= &ipv6_devconf.max_desync_factor,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 #endif
 		{
-			.procname	=	"max_addresses",
-			.data		=	&ipv6_devconf.max_addresses,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "max_addresses",
+			.data		= &ipv6_devconf.max_addresses,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"accept_ra_defrtr",
-			.data		=	&ipv6_devconf.accept_ra_defrtr,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_ra_defrtr",
+			.data		= &ipv6_devconf.accept_ra_defrtr,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"accept_ra_pinfo",
-			.data		=	&ipv6_devconf.accept_ra_pinfo,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_ra_pinfo",
+			.data		= &ipv6_devconf.accept_ra_pinfo,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		{
-			.procname	=	"accept_ra_rtr_pref",
-			.data		=	&ipv6_devconf.accept_ra_rtr_pref,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_ra_rtr_pref",
+			.data		= &ipv6_devconf.accept_ra_rtr_pref,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"router_probe_interval",
-			.data		=	&ipv6_devconf.rtr_probe_interval,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec_jiffies,
+			.procname	= "router_probe_interval",
+			.data		= &ipv6_devconf.rtr_probe_interval,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec_jiffies,
 		},
 #ifdef CONFIG_IPV6_ROUTE_INFO
 		{
-			.procname	=	"accept_ra_rt_info_max_plen",
-			.data		=	&ipv6_devconf.accept_ra_rt_info_max_plen,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_ra_rt_info_max_plen",
+			.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 #endif
 #endif
 		{
-			.procname	=	"proxy_ndp",
-			.data		=	&ipv6_devconf.proxy_ndp,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "proxy_ndp",
+			.data		= &ipv6_devconf.proxy_ndp,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
-			.procname	=	"accept_source_route",
-			.data		=	&ipv6_devconf.accept_source_route,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_source_route",
+			.data		= &ipv6_devconf.accept_source_route,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
-			.procname       =       "optimistic_dad",
-			.data           =       &ipv6_devconf.optimistic_dad,
-			.maxlen         =       sizeof(int),
-			.mode           =       0644,
-			.proc_handler   =       proc_dointvec,
+			.procname       = "optimistic_dad",
+			.data           = &ipv6_devconf.optimistic_dad,
+			.maxlen         = sizeof(int),
+			.mode           = 0644,
+			.proc_handler   = proc_dointvec,
 
 		},
 #endif
 #ifdef CONFIG_IPV6_MROUTE
 		{
-			.procname	=	"mc_forwarding",
-			.data		=	&ipv6_devconf.mc_forwarding,
-			.maxlen		=	sizeof(int),
-			.mode		=	0444,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "mc_forwarding",
+			.data		= &ipv6_devconf.mc_forwarding,
+			.maxlen		= sizeof(int),
+			.mode		= 0444,
+			.proc_handler	= proc_dointvec,
 		},
 #endif
 		{
-			.procname	=	"disable_ipv6",
-			.data		=	&ipv6_devconf.disable_ipv6,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	addrconf_sysctl_disable,
+			.procname	= "disable_ipv6",
+			.data		= &ipv6_devconf.disable_ipv6,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= addrconf_sysctl_disable,
 		},
 		{
-			.procname	=	"accept_dad",
-			.data		=	&ipv6_devconf.accept_dad,
-			.maxlen		=	sizeof(int),
-			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.procname	= "accept_dad",
+			.data		= &ipv6_devconf.accept_dad,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.procname       = "force_tllao",
@@ -4380,7 +4387,7 @@ static int __addrconf_sysctl_register(st
 		goto out;
 
 	for (i = 0; t->addrconf_vars[i].data; i++) {
-		t->addrconf_vars[i].data += (char*)p - (char*)&ipv6_devconf;
+		t->addrconf_vars[i].data += (char *)p - (char *)&ipv6_devconf;
 		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
 		t->addrconf_vars[i].extra2 = net;
 	}
@@ -4517,14 +4524,12 @@ int register_inet6addr_notifier(struct n
 {
 	return atomic_notifier_chain_register(&inet6addr_chain, nb);
 }
-
 EXPORT_SYMBOL(register_inet6addr_notifier);
 
 int unregister_inet6addr_notifier(struct notifier_block *nb)
 {
-	return atomic_notifier_chain_unregister(&inet6addr_chain,nb);
+	return atomic_notifier_chain_unregister(&inet6addr_chain, nb);
 }
-
 EXPORT_SYMBOL(unregister_inet6addr_notifier);
 
 /*
@@ -4535,9 +4540,10 @@ int __init addrconf_init(void)
 {
 	int i, err;
 
-	if ((err = ipv6_addr_label_init()) < 0) {
-		printk(KERN_CRIT "IPv6 Addrconf: cannot initialize default policy table: %d.\n",
-			err);
+	err = ipv6_addr_label_init();
+	if (err < 0) {
+		printk(KERN_CRIT "IPv6 Addrconf:"
+		       " cannot initialize default policy table: %d.\n", err);
 		return err;
 	}
 

-- 

