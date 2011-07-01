From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/12] appletalk: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:02 -0700
Message-ID: <32e307b4b4294917efc16dcb079ede14c4755f21.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the case labels the same indent as the switch.

(git diff -w net/appletalk shows no difference)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/appletalk/aarp.c |  138 +++++++++---------
 net/appletalk/ddp.c  |  398 +++++++++++++++++++++++++-------------------------
 2 files changed, 268 insertions(+), 268 deletions(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 50dce79..1acc695 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -779,87 +779,87 @@ static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	switch (function) {
-		case AARP_REPLY:
-			if (!unresolved_count)	/* Speed up */
-				break;
-
-			/* Find the entry.  */
-			a = __aarp_find_entry(unresolved[hash], dev, &sa);
-			if (!a || dev != a->dev)
-				break;
+	case AARP_REPLY:
+		if (!unresolved_count)	/* Speed up */
+			break;
 
-			/* We can fill one in - this is good. */
-			memcpy(a->hwaddr, ea->hw_src, ETH_ALEN);
-			__aarp_resolved(&unresolved[hash], a, hash);
-			if (!unresolved_count)
-				mod_timer(&aarp_timer,
-					  jiffies + sysctl_aarp_expiry_time);
+		/* Find the entry.  */
+		a = __aarp_find_entry(unresolved[hash], dev, &sa);
+		if (!a || dev != a->dev)
 			break;
 
-		case AARP_REQUEST:
-		case AARP_PROBE:
+		/* We can fill one in - this is good. */
+		memcpy(a->hwaddr, ea->hw_src, ETH_ALEN);
+		__aarp_resolved(&unresolved[hash], a, hash);
+		if (!unresolved_count)
+			mod_timer(&aarp_timer,
+				  jiffies + sysctl_aarp_expiry_time);
+		break;
+
+	case AARP_REQUEST:
+	case AARP_PROBE:
+
+		/*
+		 * If it is my address set ma to my address and reply.
+		 * We can treat probe and request the same.  Probe
+		 * simply means we shouldn't cache the querying host,
+		 * as in a probe they are proposing an address not
+		 * using one.
+		 *
+		 * Support for proxy-AARP added. We check if the
+		 * address is one of our proxies before we toss the
+		 * packet out.
+		 */
+
+		sa.s_node = ea->pa_dst_node;
+		sa.s_net  = ea->pa_dst_net;
+
+		/* See if we have a matching proxy. */
+		ma = __aarp_proxy_find(dev, &sa);
+		if (!ma)
+			ma = &ifa->address;
+		else { /* We need to make a copy of the entry. */
+			da.s_node = sa.s_node;
+			da.s_net = sa.s_net;
+			ma = &da;
+		}
 
+		if (function == AARP_PROBE) {
 			/*
-			 * If it is my address set ma to my address and reply.
-			 * We can treat probe and request the same.  Probe
-			 * simply means we shouldn't cache the querying host,
-			 * as in a probe they are proposing an address not
-			 * using one.
-			 *
-			 * Support for proxy-AARP added. We check if the
-			 * address is one of our proxies before we toss the
-			 * packet out.
+			 * A probe implies someone trying to get an
+			 * address. So as a precaution flush any
+			 * entries we have for this address.
 			 */
+			a = __aarp_find_entry(resolved[sa.s_node %
+						       (AARP_HASH_SIZE - 1)],
+					      skb->dev, &sa);
 
-			sa.s_node = ea->pa_dst_node;
-			sa.s_net  = ea->pa_dst_net;
-
-			/* See if we have a matching proxy. */
-			ma = __aarp_proxy_find(dev, &sa);
-			if (!ma)
-				ma = &ifa->address;
-			else { /* We need to make a copy of the entry. */
-				da.s_node = sa.s_node;
-				da.s_net = sa.s_net;
-				ma = &da;
-			}
-
-			if (function == AARP_PROBE) {
-				/*
-				 * A probe implies someone trying to get an
-				 * address. So as a precaution flush any
-				 * entries we have for this address.
-				 */
-				a = __aarp_find_entry(resolved[sa.s_node %
-							  (AARP_HASH_SIZE - 1)],
-						      skb->dev, &sa);
-
-				/*
-				 * Make it expire next tick - that avoids us
-				 * getting into a probe/flush/learn/probe/
-				 * flush/learn cycle during probing of a slow
-				 * to respond host addr.
-				 */
-				if (a) {
-					a->expires_at = jiffies - 1;
-					mod_timer(&aarp_timer, jiffies +
-							sysctl_aarp_tick_time);
-				}
+			/*
+			 * Make it expire next tick - that avoids us
+			 * getting into a probe/flush/learn/probe/
+			 * flush/learn cycle during probing of a slow
+			 * to respond host addr.
+			 */
+			if (a) {
+				a->expires_at = jiffies - 1;
+				mod_timer(&aarp_timer, jiffies +
+					  sysctl_aarp_tick_time);
 			}
+		}
 
-			if (sa.s_node != ma->s_node)
-				break;
+		if (sa.s_node != ma->s_node)
+			break;
 
-			if (sa.s_net && ma->s_net && sa.s_net != ma->s_net)
-				break;
+		if (sa.s_net && ma->s_net && sa.s_net != ma->s_net)
+			break;
 
-			sa.s_node = ea->pa_src_node;
-			sa.s_net = ea->pa_src_net;
+		sa.s_node = ea->pa_src_node;
+		sa.s_net = ea->pa_src_net;
 
-			/* aarp_my_address has found the address to use for us.
-			*/
-			aarp_send_reply(dev, ma, &sa, ea->hw_src);
-			break;
+		/* aarp_my_address has found the address to use for us.
+		 */
+		aarp_send_reply(dev, ma, &sa, ea->hw_src);
+		break;
 	}
 
 unlock:
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 956a530..b1fe7c3 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -684,192 +684,192 @@ static int atif_ioctl(int cmd, void __user *arg)
 	atif = atalk_find_dev(dev);
 
 	switch (cmd) {
-		case SIOCSIFADDR:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			if (sa->sat_family != AF_APPLETALK)
-				return -EINVAL;
-			if (dev->type != ARPHRD_ETHER &&
-			    dev->type != ARPHRD_LOOPBACK &&
-			    dev->type != ARPHRD_LOCALTLK &&
-			    dev->type != ARPHRD_PPP)
-				return -EPROTONOSUPPORT;
-
-			nr = (struct atalk_netrange *)&sa->sat_zero[0];
-			add_route = 1;
-
-			/*
-			 * if this is a point-to-point iface, and we already
-			 * have an iface for this AppleTalk address, then we
-			 * should not add a route
-			 */
-			if ((dev->flags & IFF_POINTOPOINT) &&
-			    atalk_find_interface(sa->sat_addr.s_net,
-						 sa->sat_addr.s_node)) {
-				printk(KERN_DEBUG "AppleTalk: point-to-point "
-						  "interface added with "
-						  "existing address\n");
-				add_route = 0;
-			}
+	case SIOCSIFADDR:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (sa->sat_family != AF_APPLETALK)
+			return -EINVAL;
+		if (dev->type != ARPHRD_ETHER &&
+		    dev->type != ARPHRD_LOOPBACK &&
+		    dev->type != ARPHRD_LOCALTLK &&
+		    dev->type != ARPHRD_PPP)
+			return -EPROTONOSUPPORT;
+
+		nr = (struct atalk_netrange *)&sa->sat_zero[0];
+		add_route = 1;
 
-			/*
-			 * Phase 1 is fine on LocalTalk but we don't do
-			 * EtherTalk phase 1. Anyone wanting to add it go ahead.
-			 */
-			if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
-				return -EPROTONOSUPPORT;
-			if (sa->sat_addr.s_node == ATADDR_BCAST ||
-			    sa->sat_addr.s_node == 254)
-				return -EINVAL;
-			if (atif) {
-				/* Already setting address */
-				if (atif->status & ATIF_PROBE)
-					return -EBUSY;
-
-				atif->address.s_net  = sa->sat_addr.s_net;
-				atif->address.s_node = sa->sat_addr.s_node;
-				atrtr_device_down(dev);	/* Flush old routes */
-			} else {
-				atif = atif_add_device(dev, &sa->sat_addr);
-				if (!atif)
-					return -ENOMEM;
-			}
-			atif->nets = *nr;
-
-			/*
-			 * Check if the chosen address is used. If so we
-			 * error and atalkd will try another.
-			 */
-
-			if (!(dev->flags & IFF_LOOPBACK) &&
-			    !(dev->flags & IFF_POINTOPOINT) &&
-			    atif_probe_device(atif) < 0) {
-				atif_drop_device(dev);
-				return -EADDRINUSE;
-			}
-
-			/* Hey it worked - add the direct routes */
-			sa = (struct sockaddr_at *)&rtdef.rt_gateway;
-			sa->sat_family = AF_APPLETALK;
-			sa->sat_addr.s_net  = atif->address.s_net;
-			sa->sat_addr.s_node = atif->address.s_node;
-			sa = (struct sockaddr_at *)&rtdef.rt_dst;
-			rtdef.rt_flags = RTF_UP;
-			sa->sat_family = AF_APPLETALK;
-			sa->sat_addr.s_node = ATADDR_ANYNODE;
-			if (dev->flags & IFF_LOOPBACK ||
-			    dev->flags & IFF_POINTOPOINT)
-				rtdef.rt_flags |= RTF_HOST;
-
-			/* Routerless initial state */
-			if (nr->nr_firstnet == htons(0) &&
-			    nr->nr_lastnet == htons(0xFFFE)) {
-				sa->sat_addr.s_net = atif->address.s_net;
-				atrtr_create(&rtdef, dev);
-				atrtr_set_default(dev);
-			} else {
-				limit = ntohs(nr->nr_lastnet);
-				if (limit - ntohs(nr->nr_firstnet) > 4096) {
-					printk(KERN_WARNING "Too many routes/"
-							    "iface.\n");
-					return -EINVAL;
-				}
-				if (add_route)
-					for (ct = ntohs(nr->nr_firstnet);
-					     ct <= limit; ct++) {
-						sa->sat_addr.s_net = htons(ct);
-						atrtr_create(&rtdef, dev);
-					}
-			}
-			dev_mc_add_global(dev, aarp_mcast);
-			return 0;
+		/*
+		 * if this is a point-to-point iface, and we already
+		 * have an iface for this AppleTalk address, then we
+		 * should not add a route
+		 */
+		if ((dev->flags & IFF_POINTOPOINT) &&
+		    atalk_find_interface(sa->sat_addr.s_net,
+					 sa->sat_addr.s_node)) {
+			printk(KERN_DEBUG "AppleTalk: point-to-point "
+			       "interface added with "
+			       "existing address\n");
+			add_route = 0;
+		}
 
-		case SIOCGIFADDR:
+		/*
+		 * Phase 1 is fine on LocalTalk but we don't do
+		 * EtherTalk phase 1. Anyone wanting to add it go ahead.
+		 */
+		if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
+			return -EPROTONOSUPPORT;
+		if (sa->sat_addr.s_node == ATADDR_BCAST ||
+		    sa->sat_addr.s_node == 254)
+			return -EINVAL;
+		if (atif) {
+			/* Already setting address */
+			if (atif->status & ATIF_PROBE)
+				return -EBUSY;
+
+			atif->address.s_net  = sa->sat_addr.s_net;
+			atif->address.s_node = sa->sat_addr.s_node;
+			atrtr_device_down(dev);	/* Flush old routes */
+		} else {
+			atif = atif_add_device(dev, &sa->sat_addr);
 			if (!atif)
-				return -EADDRNOTAVAIL;
+				return -ENOMEM;
+		}
+		atif->nets = *nr;
 
-			sa->sat_family = AF_APPLETALK;
-			sa->sat_addr = atif->address;
-			break;
+		/*
+		 * Check if the chosen address is used. If so we
+		 * error and atalkd will try another.
+		 */
 
-		case SIOCGIFBRDADDR:
-			if (!atif)
-				return -EADDRNOTAVAIL;
+		if (!(dev->flags & IFF_LOOPBACK) &&
+		    !(dev->flags & IFF_POINTOPOINT) &&
+		    atif_probe_device(atif) < 0) {
+			atif_drop_device(dev);
+			return -EADDRINUSE;
+		}
 
-			sa->sat_family = AF_APPLETALK;
+		/* Hey it worked - add the direct routes */
+		sa = (struct sockaddr_at *)&rtdef.rt_gateway;
+		sa->sat_family = AF_APPLETALK;
+		sa->sat_addr.s_net  = atif->address.s_net;
+		sa->sat_addr.s_node = atif->address.s_node;
+		sa = (struct sockaddr_at *)&rtdef.rt_dst;
+		rtdef.rt_flags = RTF_UP;
+		sa->sat_family = AF_APPLETALK;
+		sa->sat_addr.s_node = ATADDR_ANYNODE;
+		if (dev->flags & IFF_LOOPBACK ||
+		    dev->flags & IFF_POINTOPOINT)
+			rtdef.rt_flags |= RTF_HOST;
+
+		/* Routerless initial state */
+		if (nr->nr_firstnet == htons(0) &&
+		    nr->nr_lastnet == htons(0xFFFE)) {
 			sa->sat_addr.s_net = atif->address.s_net;
-			sa->sat_addr.s_node = ATADDR_BCAST;
-			break;
-
-		case SIOCATALKDIFADDR:
-		case SIOCDIFADDR:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			if (sa->sat_family != AF_APPLETALK)
+			atrtr_create(&rtdef, dev);
+			atrtr_set_default(dev);
+		} else {
+			limit = ntohs(nr->nr_lastnet);
+			if (limit - ntohs(nr->nr_firstnet) > 4096) {
+				printk(KERN_WARNING "Too many routes/"
+				       "iface.\n");
 				return -EINVAL;
-			atalk_dev_down(dev);
-			break;
-
-		case SIOCSARP:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			if (sa->sat_family != AF_APPLETALK)
-				return -EINVAL;
-			/*
-			 * for now, we only support proxy AARP on ELAP;
-			 * we should be able to do it for LocalTalk, too.
-			 */
-			if (dev->type != ARPHRD_ETHER)
-				return -EPROTONOSUPPORT;
-
-			/*
-			 * atif points to the current interface on this network;
-			 * we aren't concerned about its current status (at
-			 * least for now), but it has all the settings about
-			 * the network we're going to probe. Consequently, it
-			 * must exist.
-			 */
-			if (!atif)
-				return -EADDRNOTAVAIL;
+			}
+			if (add_route)
+				for (ct = ntohs(nr->nr_firstnet);
+				     ct <= limit; ct++) {
+					sa->sat_addr.s_net = htons(ct);
+					atrtr_create(&rtdef, dev);
+				}
+		}
+		dev_mc_add_global(dev, aarp_mcast);
+		return 0;
+
+	case SIOCGIFADDR:
+		if (!atif)
+			return -EADDRNOTAVAIL;
+
+		sa->sat_family = AF_APPLETALK;
+		sa->sat_addr = atif->address;
+		break;
+
+	case SIOCGIFBRDADDR:
+		if (!atif)
+			return -EADDRNOTAVAIL;
+
+		sa->sat_family = AF_APPLETALK;
+		sa->sat_addr.s_net = atif->address.s_net;
+		sa->sat_addr.s_node = ATADDR_BCAST;
+		break;
+
+	case SIOCATALKDIFADDR:
+	case SIOCDIFADDR:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (sa->sat_family != AF_APPLETALK)
+			return -EINVAL;
+		atalk_dev_down(dev);
+		break;
 
-			nr = (struct atalk_netrange *)&(atif->nets);
-			/*
-			 * Phase 1 is fine on Localtalk but we don't do
-			 * Ethertalk phase 1. Anyone wanting to add it go ahead.
-			 */
-			if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
-				return -EPROTONOSUPPORT;
+	case SIOCSARP:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (sa->sat_family != AF_APPLETALK)
+			return -EINVAL;
+		/*
+		 * for now, we only support proxy AARP on ELAP;
+		 * we should be able to do it for LocalTalk, too.
+		 */
+		if (dev->type != ARPHRD_ETHER)
+			return -EPROTONOSUPPORT;
 
-			if (sa->sat_addr.s_node == ATADDR_BCAST ||
-			    sa->sat_addr.s_node == 254)
-				return -EINVAL;
+		/*
+		 * atif points to the current interface on this network;
+		 * we aren't concerned about its current status (at
+		 * least for now), but it has all the settings about
+		 * the network we're going to probe. Consequently, it
+		 * must exist.
+		 */
+		if (!atif)
+			return -EADDRNOTAVAIL;
 
-			/*
-			 * Check if the chosen address is used. If so we
-			 * error and ATCP will try another.
-			 */
-			if (atif_proxy_probe_device(atif, &(sa->sat_addr)) < 0)
-				return -EADDRINUSE;
+		nr = (struct atalk_netrange *)&(atif->nets);
+		/*
+		 * Phase 1 is fine on Localtalk but we don't do
+		 * Ethertalk phase 1. Anyone wanting to add it go ahead.
+		 */
+		if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
+			return -EPROTONOSUPPORT;
 
-			/*
-			 * We now have an address on the local network, and
-			 * the AARP code will defend it for us until we take it
-			 * down. We don't set up any routes right now, because
-			 * ATCP will install them manually via SIOCADDRT.
-			 */
-			break;
+		if (sa->sat_addr.s_node == ATADDR_BCAST ||
+		    sa->sat_addr.s_node == 254)
+			return -EINVAL;
 
-		case SIOCDARP:
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			if (sa->sat_family != AF_APPLETALK)
-				return -EINVAL;
-			if (!atif)
-				return -EADDRNOTAVAIL;
+		/*
+		 * Check if the chosen address is used. If so we
+		 * error and ATCP will try another.
+		 */
+		if (atif_proxy_probe_device(atif, &(sa->sat_addr)) < 0)
+			return -EADDRINUSE;
 
-			/* give to aarp module to remove proxy entry */
-			aarp_proxy_remove(atif->dev, &(sa->sat_addr));
-			return 0;
+		/*
+		 * We now have an address on the local network, and
+		 * the AARP code will defend it for us until we take it
+		 * down. We don't set up any routes right now, because
+		 * ATCP will install them manually via SIOCADDRT.
+		 */
+		break;
+
+	case SIOCDARP:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (sa->sat_family != AF_APPLETALK)
+			return -EINVAL;
+		if (!atif)
+			return -EADDRNOTAVAIL;
+
+		/* give to aarp module to remove proxy entry */
+		aarp_proxy_remove(atif->dev, &(sa->sat_addr));
+		return 0;
 	}
 
 	return copy_to_user(arg, &atreq, sizeof(atreq)) ? -EFAULT : 0;
@@ -884,25 +884,25 @@ static int atrtr_ioctl(unsigned int cmd, void __user *arg)
 		return -EFAULT;
 
 	switch (cmd) {
-		case SIOCDELRT:
-			if (rt.rt_dst.sa_family != AF_APPLETALK)
-				return -EINVAL;
-			return atrtr_delete(&((struct sockaddr_at *)
-						&rt.rt_dst)->sat_addr);
-
-		case SIOCADDRT: {
-			struct net_device *dev = NULL;
-			if (rt.rt_dev) {
-				char name[IFNAMSIZ];
-				if (copy_from_user(name, rt.rt_dev, IFNAMSIZ-1))
-					return -EFAULT;
-				name[IFNAMSIZ-1] = '\0';
-				dev = __dev_get_by_name(&init_net, name);
-				if (!dev)
-					return -ENODEV;
-			}
-			return atrtr_create(&rt, dev);
+	case SIOCDELRT:
+		if (rt.rt_dst.sa_family != AF_APPLETALK)
+			return -EINVAL;
+		return atrtr_delete(&((struct sockaddr_at *)
+				      &rt.rt_dst)->sat_addr);
+
+	case SIOCADDRT: {
+		struct net_device *dev = NULL;
+		if (rt.rt_dev) {
+			char name[IFNAMSIZ];
+			if (copy_from_user(name, rt.rt_dev, IFNAMSIZ-1))
+				return -EFAULT;
+			name[IFNAMSIZ-1] = '\0';
+			dev = __dev_get_by_name(&init_net, name);
+			if (!dev)
+				return -ENODEV;
 		}
+		return atrtr_create(&rt, dev);
+	}
 	}
 	return -EINVAL;
 }
-- 
1.7.6.rc1
