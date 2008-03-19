From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH] [RFC] [IPv6] spelling fix in /proc:
	/proc/sys/net/ipv6/conf/default/temp_prefered_lft
Date: Wed, 19 Mar 2008 21:42:27 +0100
Message-ID: <20080319204227.GF6935@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:41238 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934628AbYCSUme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:42:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a way to fix a bad spelling in /proc ?

Here is a patch to fix all the spelling error (prefered -> preferred)
in the ipv6 code. I didn't change the /proc name but everything else is
changed.
Currently you can found both spelling in the ipv6 code.
Is it ok ?

regards,

Benoit

diff -r ef957e3033e5 include/linux/if_addr.h
--- a/include/linux/if_addr.h	Wed Mar 19 21:01:45 2008 +0100
+++ b/include/linux/if_addr.h	Wed Mar 19 21:39:40 2008 +0100
@@ -47,7 +47,7 @@
 
 struct ifa_cacheinfo
 {
-	__u32	ifa_prefered;
+	__u32	ifa_preferred;
 	__u32	ifa_valid;
 	__u32	cstamp; /* created timestamp, hundredths of seconds */
 	__u32	tstamp; /* updated timestamp, hundredths of seconds */
diff -r ef957e3033e5 include/linux/ipv6.h
--- a/include/linux/ipv6.h	Wed Mar 19 21:01:45 2008 +0100
+++ b/include/linux/ipv6.h	Wed Mar 19 21:39:40 2008 +0100
@@ -141,7 +141,7 @@
 #ifdef CONFIG_IPV6_PRIVACY
 	__s32		use_tempaddr;
 	__s32		temp_valid_lft;
-	__s32		temp_prefered_lft;
+	__s32		temp_preferred_lft;
 	__s32		regen_max_retry;
 	__s32		max_desync_factor;
 #endif
@@ -177,7 +177,7 @@
 	DEVCONF_RTR_SOLICIT_DELAY,
 	DEVCONF_USE_TEMPADDR,
 	DEVCONF_TEMP_VALID_LFT,
-	DEVCONF_TEMP_PREFERED_LFT,
+	DEVCONF_TEMP_PREFERRED_LFT,
 	DEVCONF_REGEN_MAX_RETRY,
 	DEVCONF_MAX_DESYNC_FACTOR,
 	DEVCONF_MAX_ADDRESSES,
diff -r ef957e3033e5 include/linux/sysctl.h
--- a/include/linux/sysctl.h	Wed Mar 19 21:01:45 2008 +0100
+++ b/include/linux/sysctl.h	Wed Mar 19 21:39:40 2008 +0100
@@ -566,7 +566,7 @@
 	NET_IPV6_RTR_SOLICIT_DELAY=10,
 	NET_IPV6_USE_TEMPADDR=11,
 	NET_IPV6_TEMP_VALID_LFT=12,
-	NET_IPV6_TEMP_PREFERED_LFT=13,
+	NET_IPV6_TEMP_PREFERRED_LFT=13,
 	NET_IPV6_REGEN_MAX_RETRY=14,
 	NET_IPV6_MAX_DESYNC_FACTOR=15,
 	NET_IPV6_MAX_ADDRESSES=16,
diff -r ef957e3033e5 include/net/addrconf.h
--- a/include/net/addrconf.h	Wed Mar 19 21:01:45 2008 +0100
+++ b/include/net/addrconf.h	Wed Mar 19 21:39:40 2008 +0100
@@ -37,7 +37,7 @@
 #error "Please fix <asm/byteorder.h>"
 #endif
 	__be32			valid;
-	__be32			prefered;
+	__be32			preferred;
 	__be32			reserved2;
 
 	struct in6_addr		prefix;
diff -r ef957e3033e5 include/net/if_inet6.h
--- a/include/net/if_inet6.h	Wed Mar 19 21:01:45 2008 +0100
+++ b/include/net/if_inet6.h	Wed Mar 19 21:39:40 2008 +0100
@@ -38,7 +38,7 @@
 	__u32			prefix_len;
 	
 	__u32			valid_lft;
-	__u32			prefered_lft;
+	__u32			preferred_lft;
 	unsigned long		cstamp;	/* created timestamp */
 	unsigned long		tstamp; /* updated timestamp */
 	atomic_t		refcnt;
diff -r ef957e3033e5 kernel/sysctl_check.c
--- a/kernel/sysctl_check.c	Wed Mar 19 21:01:45 2008 +0100
+++ b/kernel/sysctl_check.c	Wed Mar 19 21:39:40 2008 +0100
@@ -482,7 +482,7 @@
 	{ NET_IPV6_RTR_SOLICIT_DELAY,		"router_solicitation_delay" },
 	{ NET_IPV6_USE_TEMPADDR,		"use_tempaddr" },
 	{ NET_IPV6_TEMP_VALID_LFT,		"temp_valid_lft" },
-	{ NET_IPV6_TEMP_PREFERED_LFT,		"temp_prefered_lft" },
+	{ NET_IPV6_TEMP_PREFERRED_LFT,		"temp_prefered_lft" },
 	{ NET_IPV6_REGEN_MAX_RETRY,		"regen_max_retry" },
 	{ NET_IPV6_MAX_DESYNC_FACTOR,		"max_desync_factor" },
 	{ NET_IPV6_MAX_ADDRESSES,		"max_addresses" },
diff -r ef957e3033e5 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Wed Mar 19 21:01:45 2008 +0100
+++ b/net/ipv6/addrconf.c	Wed Mar 19 21:39:40 2008 +0100
@@ -169,7 +169,7 @@
 #ifdef CONFIG_IPV6_PRIVACY
 	.use_tempaddr 		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
-	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
+	.temp_preferred_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
 	.max_desync_factor	= MAX_DESYNC_FACTOR,
 #endif
@@ -201,7 +201,7 @@
 #ifdef CONFIG_IPV6_PRIVACY
 	.use_tempaddr		= 0,
 	.temp_valid_lft		= TEMP_VALID_LIFETIME,
-	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
+	.temp_preferred_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
 	.max_desync_factor	= MAX_DESYNC_FACTOR,
 #endif
@@ -775,7 +775,7 @@
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
+	unsigned long tmp_preferred_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
@@ -827,9 +827,9 @@
 	tmp_valid_lft = min_t(__u32,
 			      ifp->valid_lft,
 			      idev->cnf.temp_valid_lft);
-	tmp_prefered_lft = min_t(__u32,
-				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
+	tmp_preferred_lft = min_t(__u32,
+				 ifp->preferred_lft,
+				 idev->cnf.temp_preferred_lft - desync_factor / HZ);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;
 	tmp_cstamp = ifp->cstamp;
@@ -861,7 +861,7 @@
 	spin_lock_bh(&ift->lock);
 	ift->ifpub = ifp;
 	ift->valid_lft = tmp_valid_lft;
-	ift->prefered_lft = tmp_prefered_lft;
+	ift->preferred_lft = tmp_preferred_lft;
 	ift->cstamp = tmp_cstamp;
 	ift->tstamp = tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
@@ -1515,7 +1515,7 @@
 		goto out;
 
 	expires = jiffies +
-		idev->cnf.temp_prefered_lft * HZ -
+		idev->cnf.temp_preferred_lft * HZ -
 		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time - desync_factor;
 	if (time_before(expires, jiffies)) {
 		printk(KERN_WARNING
@@ -1638,7 +1638,7 @@
 {
 	struct prefix_info *pinfo;
 	__u32 valid_lft;
-	__u32 prefered_lft;
+	__u32 preferred_lft;
 	int addr_type;
 	unsigned long rt_expires;
 	struct inet6_dev *in6_dev;
@@ -1660,9 +1660,9 @@
 		return;
 
 	valid_lft = ntohl(pinfo->valid);
-	prefered_lft = ntohl(pinfo->prefered);
-
-	if (prefered_lft > valid_lft) {
+	preferred_lft = ntohl(pinfo->preferred);
+
+	if (preferred_lft > valid_lft) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "addrconf: prefix option has invalid lifetime\n");
 		return;
@@ -1801,15 +1801,15 @@
 					update_lft = 0;
 				} else {
 					valid_lft = MIN_VALID_LIFETIME;
-					if (valid_lft < prefered_lft)
-						prefered_lft = valid_lft;
+					if (valid_lft < preferred_lft)
+						preferred_lft = valid_lft;
 					update_lft = 1;
 				}
 			}
 
 			if (update_lft) {
 				ifp->valid_lft = valid_lft;
-				ifp->prefered_lft = prefered_lft;
+				ifp->preferred_lft = preferred_lft;
 				ifp->tstamp = now;
 				flags = ifp->flags;
 				ifp->flags &= ~IFA_F_DEPRECATED;
@@ -1836,9 +1836,9 @@
 				if (ift->valid_lft > valid_lft &&
 				    ift->valid_lft - valid_lft > (jiffies - ift->tstamp) / HZ)
 					ift->valid_lft = valid_lft + (jiffies - ift->tstamp) / HZ;
-				if (ift->prefered_lft > prefered_lft &&
-				    ift->prefered_lft - prefered_lft > (jiffies - ift->tstamp) / HZ)
-					ift->prefered_lft = prefered_lft + (jiffies - ift->tstamp) / HZ;
+				if (ift->preferred_lft > preferred_lft &&
+				    ift->preferred_lft - preferred_lft > (jiffies - ift->tstamp) / HZ)
+					ift->preferred_lft = preferred_lft + (jiffies - ift->tstamp) / HZ;
 				spin_unlock(&ift->lock);
 				if (!(flags&IFA_F_TENTATIVE))
 					ipv6_ifa_notify(0, ift);
@@ -1927,7 +1927,7 @@
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
-			  __u8 ifa_flags, __u32 prefered_lft, __u32 valid_lft)
+			  __u8 ifa_flags, __u32 preferred_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
@@ -1938,7 +1938,7 @@
 	ASSERT_RTNL();
 
 	/* check the lifetime */
-	if (!valid_lft || prefered_lft > valid_lft)
+	if (!valid_lft || preferred_lft > valid_lft)
 		return -EINVAL;
 
 	if ((dev = __dev_get_by_index(&init_net, ifindex)) == NULL)
@@ -1955,18 +1955,18 @@
 	} else if (valid_lft >= 0x7FFFFFFF/HZ)
 		valid_lft = 0x7FFFFFFF/HZ;
 
-	if (prefered_lft == 0)
+	if (preferred_lft == 0)
 		ifa_flags |= IFA_F_DEPRECATED;
-	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
-		 (prefered_lft != INFINITY_LIFE_TIME))
-		prefered_lft = 0x7FFFFFFF/HZ;
+	else if ((preferred_lft >= 0x7FFFFFFF/HZ) &&
+		 (preferred_lft != INFINITY_LIFE_TIME))
+		preferred_lft = 0x7FFFFFFF/HZ;
 
 	ifp = ipv6_add_addr(idev, pfx, plen, scope, ifa_flags);
 
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->valid_lft = valid_lft;
-		ifp->prefered_lft = prefered_lft;
+		ifp->preferred_lft = preferred_lft;
 		ifp->tstamp = jiffies;
 		spin_unlock_bh(&ifp->lock);
 
@@ -2953,11 +2953,11 @@
 				read_unlock(&addrconf_hash_lock);
 				ipv6_del_addr(ifp);
 				goto restart;
-			} else if (ifp->prefered_lft == INFINITY_LIFE_TIME) {
-				spin_unlock(&ifp->lock);
-				continue;
-			} else if (age >= ifp->prefered_lft) {
-				/* jiffies - ifp->tsamp > age >= ifp->prefered_lft */
+			} else if (ifp->preferred_lft == INFINITY_LIFE_TIME) {
+				spin_unlock(&ifp->lock);
+				continue;
+			} else if (age >= ifp->preferred_lft) {
+				/* jiffies - ifp->tsamp > age >= ifp->preferred_lft */
 				int deprecate = 0;
 
 				if (!(ifp->flags&IFA_F_DEPRECATED)) {
@@ -2981,10 +2981,10 @@
 #ifdef CONFIG_IPV6_PRIVACY
 			} else if ((ifp->flags&IFA_F_TEMPORARY) &&
 				   !(ifp->flags&IFA_F_TENTATIVE)) {
-				if (age >= ifp->prefered_lft - regen_advance) {
+				if (age >= ifp->preferred_lft - regen_advance) {
 					struct inet6_ifaddr *ifpub = ifp->ifpub;
-					if (time_before(ifp->tstamp + ifp->prefered_lft * HZ, next))
-						next = ifp->tstamp + ifp->prefered_lft * HZ;
+					if (time_before(ifp->tstamp + ifp->preferred_lft * HZ, next))
+						next = ifp->tstamp + ifp->preferred_lft * HZ;
 					if (!ifp->regen_count && ifpub) {
 						ifp->regen_count++;
 						in6_ifa_hold(ifp);
@@ -2999,14 +2999,14 @@
 						in6_ifa_put(ifp);
 						goto restart;
 					}
-				} else if (time_before(ifp->tstamp + ifp->prefered_lft * HZ - regen_advance * HZ, next))
-					next = ifp->tstamp + ifp->prefered_lft * HZ - regen_advance * HZ;
-				spin_unlock(&ifp->lock);
-#endif
-			} else {
-				/* ifp->prefered_lft <= ifp->valid_lft */
-				if (time_before(ifp->tstamp + ifp->prefered_lft * HZ, next))
-					next = ifp->tstamp + ifp->prefered_lft * HZ;
+				} else if (time_before(ifp->tstamp + ifp->preferred_lft * HZ - regen_advance * HZ, next))
+					next = ifp->tstamp + ifp->preferred_lft * HZ - regen_advance * HZ;
+				spin_unlock(&ifp->lock);
+#endif
+			} else {
+				/* ifp->preferred_lft <= ifp->valid_lft */
+				if (time_before(ifp->tstamp + ifp->preferred_lft * HZ, next))
+					next = ifp->tstamp + ifp->preferred_lft * HZ;
 				spin_unlock(&ifp->lock);
 			}
 		}
@@ -3066,11 +3066,11 @@
 }
 
 static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
-			     u32 prefered_lft, u32 valid_lft)
+			     u32 preferred_lft, u32 valid_lft)
 {
 	u32 flags = RTF_EXPIRES;
 
-	if (!valid_lft || (prefered_lft > valid_lft))
+	if (!valid_lft || (preferred_lft > valid_lft))
 		return -EINVAL;
 
 	if (valid_lft == INFINITY_LIFE_TIME) {
@@ -3079,17 +3079,17 @@
 	} else if (valid_lft >= 0x7FFFFFFF/HZ)
 		valid_lft = 0x7FFFFFFF/HZ;
 
-	if (prefered_lft == 0)
+	if (preferred_lft == 0)
 		ifa_flags |= IFA_F_DEPRECATED;
-	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
-		 (prefered_lft != INFINITY_LIFE_TIME))
-		prefered_lft = 0x7FFFFFFF/HZ;
+	else if ((preferred_lft >= 0x7FFFFFFF/HZ) &&
+		 (preferred_lft != INFINITY_LIFE_TIME))
+		preferred_lft = 0x7FFFFFFF/HZ;
 
 	spin_lock_bh(&ifp->lock);
 	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
-	ifp->prefered_lft = prefered_lft;
+	ifp->preferred_lft = preferred_lft;
 
 	spin_unlock_bh(&ifp->lock);
 	if (!(ifp->flags&IFA_F_TENTATIVE))
@@ -3132,7 +3132,7 @@
 
 		ci = nla_data(tb[IFA_CACHEINFO]);
 		valid_lft = ci->ifa_valid;
-		preferred_lft = ci->ifa_prefered;
+		preferred_lft = ci->ifa_preferred;
 	} else {
 		preferred_lft = INFINITY_LIFE_TIME;
 		valid_lft = INFINITY_LIFE_TIME;
@@ -3188,7 +3188,7 @@
 			+ TIME_DELTA(cstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
 	ci.tstamp = (u32)(TIME_DELTA(tstamp, INITIAL_JIFFIES) / HZ * 100
 			+ TIME_DELTA(tstamp, INITIAL_JIFFIES) % HZ * 100 / HZ);
-	ci.ifa_prefered = preferred;
+	ci.ifa_preferred = preferred;
 	ci.ifa_valid = valid;
 
 	return nla_put(skb, IFA_CACHEINFO, sizeof(ci), &ci);
@@ -3227,7 +3227,7 @@
 		      ifa->idev->dev->ifindex);
 
 	if (!(ifa->flags&IFA_F_PERMANENT)) {
-		preferred = ifa->prefered_lft;
+		preferred = ifa->preferred_lft;
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
 			long tval = (jiffies - ifa->tstamp)/HZ;
@@ -3517,7 +3517,7 @@
 #ifdef CONFIG_IPV6_PRIVACY
 	array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
 	array[DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
-	array[DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
+	array[DEVCONF_TEMP_PREFERRED_LFT] = cnf->temp_preferred_lft;
 	array[DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
 	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
 #endif
@@ -3740,7 +3740,7 @@
 
 	NLA_PUT(skb, PREFIX_ADDRESS, sizeof(pinfo->prefix), &pinfo->prefix);
 
-	ci.preferred_time = ntohl(pinfo->prefered);
+	ci.preferred_time = ntohl(pinfo->preferred);
 	ci.valid_time = ntohl(pinfo->valid);
 	NLA_PUT(skb, PREFIX_CACHEINFO, sizeof(ci), &ci);
 
@@ -3981,9 +3981,9 @@
 			.proc_handler	=	&proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_TEMP_PREFERED_LFT,
+			.ctl_name	=	NET_IPV6_TEMP_PREFERRED_LFT,
 			.procname	=	"temp_prefered_lft",
-			.data		=	&ipv6_devconf.temp_prefered_lft,
+			.data		=	&ipv6_devconf.temp_preferred_lft,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
 			.proc_handler	=	&proc_dointvec,

-- 
:wq
