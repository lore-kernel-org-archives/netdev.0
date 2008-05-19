From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [NDISC]: Add missing strategies for per-device retrans
 timer/reachable time settings.
Date: Mon, 19 May 2008 18:52:31 +0900 (JST)
Message-ID: <20080519.185231.34522546.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, viro@ftp.linux.org.uk,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34751 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399AbYESJwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 05:52:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed from Al Viro <viro@ftp.linux.org.uk> via David Miller
<davem@davemloft.net>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 9c451ff..a01b7c4 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -129,6 +129,10 @@ extern int 			ndisc_ifinfo_sysctl_change(struct ctl_table *ctl,
 							   void __user *buffer,
 							   size_t *lenp,
 							   loff_t *ppos);
+int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
+				 int nlen, void __user *oldval,
+				 size_t __user *oldlenp,
+				 void __user *newval, size_t newlen);
 #endif
 
 extern void 			inet6_ifinfo_notify(int event,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..8dd9155 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4242,7 +4242,7 @@ static void addrconf_sysctl_register(struct inet6_dev *idev)
 	neigh_sysctl_register(idev->dev, idev->nd_parms, NET_IPV6,
 			      NET_IPV6_NEIGH, "ipv6",
 			      &ndisc_ifinfo_sysctl_change,
-			      NULL);
+			      ndisc_ifinfo_sysctl_strategy);
 	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
 			idev->dev->ifindex, idev, &idev->cnf);
 }
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2c74885..3347fcc 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1727,10 +1727,10 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * f
 	return ret;
 }
 
-static int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
-					int nlen, void __user *oldval,
-					size_t __user *oldlenp,
-					void __user *newval, size_t newlen)
+int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
+				 int nlen, void __user *oldval,
+				 size_t __user *oldlenp,
+				 void __user *newval, size_t newlen)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
