From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: use RFC2553 constant
Date: Sun, 23 Mar 2003 01:35:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030323.013532.24422763.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use RFC2553 constant variable.

Patch is for linux-2.5.65 + ChangeSet 1.1188 and depends on my
use "const" qualifier patch.

Thanks in advance.

Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.8.4.2
retrieving revision 1.1.1.8.4.3
diff -u -r1.1.1.8.4.2 -r1.1.1.8.4.3
--- net/ipv6/addrconf.c	22 Mar 2003 15:01:28 -0000	1.1.1.8.4.2
+++ net/ipv6/addrconf.c	22 Mar 2003 15:16:50 -0000	1.1.1.8.4.3
@@ -1646,7 +1646,6 @@
 
 static void init_loopback(struct net_device *dev)
 {
-	struct in6_addr addr;
 	struct inet6_dev  *idev;
 	struct inet6_ifaddr * ifp;
 
@@ -1654,15 +1653,12 @@
 
 	ASSERT_RTNL();
 
-	memset(&addr, 0, sizeof(struct in6_addr));
-	addr.s6_addr[15] = 1;
-
 	if ((idev = ipv6_find_idev(dev)) == NULL) {
 		printk(KERN_DEBUG "init loopback: add_dev failed\n");
 		return;
 	}
 
-	ifp = ipv6_add_addr(idev, &addr, 128, IFA_HOST, IFA_F_PERMANENT);
+	ifp = ipv6_add_addr(idev, &in6addr_loopback, 128, IFA_HOST, IFA_F_PERMANENT);
 	if (ifp) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &= ~IFA_F_TENTATIVE;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
