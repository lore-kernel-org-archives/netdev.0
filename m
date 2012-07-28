From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH] net:appletalk:ddp:fixed some codystyle issues in
Date: Sat, 28 Jul 2012 16:15:07 +0530
Message-ID: <1343472307-4697-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: joe@perches.com, acme@ghostprotocols.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm34-vm5.bullet.mail.sg3.yahoo.com ([106.10.151.244]:39490 "HELO
	nm34-vm5.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751830Ab2G1Kpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 06:45:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed coding style issues relating to indentation found in
net/appletalkddp.c."git diff -w" is empty and the compiled objects
are the same too.

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/appletalk/ddp.c |  212 +++++++++++++++++++++++++--------------------------
 1 file changed, 106 insertions(+), 106 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index c8bbcd2..19b7058 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -337,7 +337,7 @@ static int atif_proxy_probe_device(struct atalk_iface *atif,
 
 	return -EADDRINUSE;	/* Network is full... */
 }
-
+   
 
 struct atalk_addr *atalk_find_dev_addr(struct net_device *dev)
 {
@@ -685,26 +685,26 @@ static int atif_ioctl(int cmd, void __user *arg)
 
 	switch (cmd) {
 	case SIOCSIFADDR:
-		if (!capable(CAP_NET_ADMIN))
+			if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (sa->sat_family != AF_APPLETALK)
+			if (sa->sat_family != AF_APPLETALK)
 			return -EINVAL;
-		if (dev->type != ARPHRD_ETHER &&
-		    dev->type != ARPHRD_LOOPBACK &&
-		    dev->type != ARPHRD_LOCALTLK &&
-		    dev->type != ARPHRD_PPP)
+			if (dev->type != ARPHRD_ETHER &&
+		    	dev->type != ARPHRD_LOOPBACK &&
+		    	dev->type != ARPHRD_LOCALTLK &&
+		    	dev->type != ARPHRD_PPP)
 			return -EPROTONOSUPPORT;
 
-		nr = (struct atalk_netrange *)&sa->sat_zero[0];
-		add_route = 1;
+			nr = (struct atalk_netrange *)&sa->sat_zero[0];
+			add_route = 1;
 
-		/*
-		 * if this is a point-to-point iface, and we already
-		 * have an iface for this AppleTalk address, then we
-		 * should not add a route
-		 */
-		if ((dev->flags & IFF_POINTOPOINT) &&
-		    atalk_find_interface(sa->sat_addr.s_net,
+			/*
+			 * if this is a point-to-point iface, and we already
+			 * have an iface for this AppleTalk address, then we
+			 * should not add a route
+			 */
+			if ((dev->flags & IFF_POINTOPOINT) &&
+			    atalk_find_interface(sa->sat_addr.s_net,
 					 sa->sat_addr.s_node)) {
 			printk(KERN_DEBUG "AppleTalk: point-to-point "
 			       "interface added with "
@@ -712,16 +712,16 @@ static int atif_ioctl(int cmd, void __user *arg)
 			add_route = 0;
 		}
 
-		/*
-		 * Phase 1 is fine on LocalTalk but we don't do
-		 * EtherTalk phase 1. Anyone wanting to add it go ahead.
-		 */
-		if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
+			/*
+			 * Phase 1 is fine on LocalTalk but we don't do
+			 * EtherTalk phase 1. Anyone wanting to add it go ahead.
+			 */
+			if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
 			return -EPROTONOSUPPORT;
-		if (sa->sat_addr.s_node == ATADDR_BCAST ||
-		    sa->sat_addr.s_node == 254)
+			if (sa->sat_addr.s_node == ATADDR_BCAST ||
+		   	 sa->sat_addr.s_node == 254)
 			return -EINVAL;
-		if (atif) {
+			if (atif) {
 			/* Already setting address */
 			if (atif->status & ATIF_PROBE)
 				return -EBUSY;
@@ -734,36 +734,36 @@ static int atif_ioctl(int cmd, void __user *arg)
 			if (!atif)
 				return -ENOMEM;
 		}
-		atif->nets = *nr;
+			atif->nets = *nr;
 
-		/*
-		 * Check if the chosen address is used. If so we
-		 * error and atalkd will try another.
-		 */
+			/*
+			 * Check if the chosen address is used. If so we
+			 * error and atalkd will try another.
+			 */
 
-		if (!(dev->flags & IFF_LOOPBACK) &&
-		    !(dev->flags & IFF_POINTOPOINT) &&
-		    atif_probe_device(atif) < 0) {
-			atif_drop_device(dev);
+			if (!(dev->flags & IFF_LOOPBACK) &&
+			    !(dev->flags & IFF_POINTOPOINT) &&
+		   	 atif_probe_device(atif) < 0) {
+				atif_drop_device(dev);
 			return -EADDRINUSE;
 		}
 
-		/* Hey it worked - add the direct routes */
-		sa = (struct sockaddr_at *)&rtdef.rt_gateway;
-		sa->sat_family = AF_APPLETALK;
-		sa->sat_addr.s_net  = atif->address.s_net;
-		sa->sat_addr.s_node = atif->address.s_node;
-		sa = (struct sockaddr_at *)&rtdef.rt_dst;
-		rtdef.rt_flags = RTF_UP;
-		sa->sat_family = AF_APPLETALK;
-		sa->sat_addr.s_node = ATADDR_ANYNODE;
-		if (dev->flags & IFF_LOOPBACK ||
-		    dev->flags & IFF_POINTOPOINT)
+			/* Hey it worked - add the direct routes */
+			sa = (struct sockaddr_at *)&rtdef.rt_gateway;
+			sa->sat_family = AF_APPLETALK;
+			sa->sat_addr.s_net  = atif->address.s_net;
+			sa->sat_addr.s_node = atif->address.s_node;
+			sa = (struct sockaddr_at *)&rtdef.rt_dst;
+			rtdef.rt_flags = RTF_UP;
+			sa->sat_family = AF_APPLETALK;
+			sa->sat_addr.s_node = ATADDR_ANYNODE;
+			if (dev->flags & IFF_LOOPBACK ||
+			    dev->flags & IFF_POINTOPOINT)
 			rtdef.rt_flags |= RTF_HOST;
 
-		/* Routerless initial state */
-		if (nr->nr_firstnet == htons(0) &&
-		    nr->nr_lastnet == htons(0xFFFE)) {
+			/* Routerless initial state */
+			if (nr->nr_firstnet == htons(0) &&
+			    nr->nr_lastnet == htons(0xFFFE)) {
 			sa->sat_addr.s_net = atif->address.s_net;
 			atrtr_create(&rtdef, dev);
 			atrtr_set_default(dev);
@@ -781,98 +781,98 @@ static int atif_ioctl(int cmd, void __user *arg)
 					atrtr_create(&rtdef, dev);
 				}
 		}
-		dev_mc_add_global(dev, aarp_mcast);
-		return 0;
+			dev_mc_add_global(dev, aarp_mcast);
+			return 0;
 
 	case SIOCGIFADDR:
-		if (!atif)
-			return -EADDRNOTAVAIL;
+			if (!atif)
+				return -EADDRNOTAVAIL;
 
-		sa->sat_family = AF_APPLETALK;
-		sa->sat_addr = atif->address;
-		break;
+			sa->sat_family = AF_APPLETALK;
+			sa->sat_addr = atif->address;
+			break;
 
 	case SIOCGIFBRDADDR:
-		if (!atif)
+			if (!atif)
 			return -EADDRNOTAVAIL;
 
-		sa->sat_family = AF_APPLETALK;
-		sa->sat_addr.s_net = atif->address.s_net;
-		sa->sat_addr.s_node = ATADDR_BCAST;
-		break;
+			sa->sat_family = AF_APPLETALK;
+			sa->sat_addr.s_net = atif->address.s_net;
+			sa->sat_addr.s_node = ATADDR_BCAST;
+			break;
 
 	case SIOCATALKDIFADDR:
 	case SIOCDIFADDR:
-		if (!capable(CAP_NET_ADMIN))
+			if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (sa->sat_family != AF_APPLETALK)
+			if (sa->sat_family != AF_APPLETALK)
 			return -EINVAL;
-		atalk_dev_down(dev);
-		break;
+			atalk_dev_down(dev);
+			break;
 
 	case SIOCSARP:
-		if (!capable(CAP_NET_ADMIN))
+			if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (sa->sat_family != AF_APPLETALK)
+			if (sa->sat_family != AF_APPLETALK)
 			return -EINVAL;
-		/*
-		 * for now, we only support proxy AARP on ELAP;
-		 * we should be able to do it for LocalTalk, too.
-		 */
-		if (dev->type != ARPHRD_ETHER)
+			/*
+			 * for now, we only support proxy AARP on ELAP;
+			 * we should be able to do it for LocalTalk, too.
+			 */
+			if (dev->type != ARPHRD_ETHER)
 			return -EPROTONOSUPPORT;
 
-		/*
-		 * atif points to the current interface on this network;
-		 * we aren't concerned about its current status (at
-		 * least for now), but it has all the settings about
-		 * the network we're going to probe. Consequently, it
-		 * must exist.
-		 */
-		if (!atif)
+			/*
+			 * atif points to the current interface on this network;
+			 * we aren't concerned about its current status (at
+			 * least for now), but it has all the settings about
+			 * the network we're going to probe. Consequently, it
+			 * must exist.
+			 */
+			if (!atif)
 			return -EADDRNOTAVAIL;
 
-		nr = (struct atalk_netrange *)&(atif->nets);
-		/*
-		 * Phase 1 is fine on Localtalk but we don't do
-		 * Ethertalk phase 1. Anyone wanting to add it go ahead.
-		 */
-		if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
+			nr = (struct atalk_netrange *)&(atif->nets);
+			/*
+			 * Phase 1 is fine on Localtalk but we don't do
+			 * Ethertalk phase 1. Anyone wanting to add it go ahead.
+			 */
+			if (dev->type == ARPHRD_ETHER && nr->nr_phase != 2)
 			return -EPROTONOSUPPORT;
 
-		if (sa->sat_addr.s_node == ATADDR_BCAST ||
-		    sa->sat_addr.s_node == 254)
+			if (sa->sat_addr.s_node == ATADDR_BCAST ||
+			    sa->sat_addr.s_node == 254)
 			return -EINVAL;
 
-		/*
-		 * Check if the chosen address is used. If so we
-		 * error and ATCP will try another.
-		 */
-		if (atif_proxy_probe_device(atif, &(sa->sat_addr)) < 0)
+			/*
+			 * Check if the chosen address is used. If so we
+			 * error and ATCP will try another.
+			 */
+			if (atif_proxy_probe_device(atif, &(sa->sat_addr)) < 0)
 			return -EADDRINUSE;
 
-		/*
-		 * We now have an address on the local network, and
-		 * the AARP code will defend it for us until we take it
-		 * down. We don't set up any routes right now, because
-		 * ATCP will install them manually via SIOCADDRT.
-		 */
-		break;
+			/*
+			 * We now have an address on the local network, and
+			 * the AARP code will defend it for us until we take it
+			 * down. We don't set up any routes right now, because
+			 * ATCP will install them manually via SIOCADDRT.
+			 */
+			break;
 
 	case SIOCDARP:
-		if (!capable(CAP_NET_ADMIN))
+			if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (sa->sat_family != AF_APPLETALK)
-			return -EINVAL;
-		if (!atif)
+			if (sa->sat_family != AF_APPLETALK)
+				return -EINVAL;
+			if (!atif)
 			return -EADDRNOTAVAIL;
 
-		/* give to aarp module to remove proxy entry */
-		aarp_proxy_remove(atif->dev, &(sa->sat_addr));
-		return 0;
+			/* give to aarp module to remove proxy entry */
+			aarp_proxy_remove(atif->dev, &(sa->sat_addr));
+			return 0;
 	}
 
-	return copy_to_user(arg, &atreq, sizeof(atreq)) ? -EFAULT : 0;
+			return copy_to_user(arg, &atreq, sizeof(atreq)) ? -EFAULT : 0;
 }
 
 /* Routing ioctl() calls */
-- 
1.7.10
