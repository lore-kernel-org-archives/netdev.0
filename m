From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: use ipv6_addr_any() for testing unspecified address
Date: Sun, 23 Mar 2003 01:35:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030323.013535.60875023.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use ipv6_addr_any() for testing unspecified address.
Patch is for linux-2.5.65 + ChangeSet 1.1188.
This should be suitable for linux-2.4.x.

Thanks in advance.

Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.8.4.3
retrieving revision 1.1.1.8.4.4
diff -u -r1.1.1.8.4.3 -r1.1.1.8.4.4
--- net/ipv6/addrconf.c	22 Mar 2003 15:16:50 -0000	1.1.1.8.4.3
+++ net/ipv6/addrconf.c	22 Mar 2003 15:27:05 -0000	1.1.1.8.4.4
@@ -426,8 +426,7 @@
 	}
 	for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
 		ipv6_addr_prefix(&addr, &ifa->addr, ifa->prefix_len);
-		if (addr.s6_addr32[0] == 0 && addr.s6_addr32[1] == 0 &&
-		    addr.s6_addr32[2] == 0 && addr.s6_addr32[3] == 0)
+		if (ipv6_addr_any(&addr))
 			continue;
 		if (idev->cnf.forwarding)
 			ipv6_dev_ac_inc(idev->dev, &addr);
@@ -2030,8 +2029,7 @@
 		struct in6_addr addr;
 
 		ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
-		if (addr.s6_addr32[0] || addr.s6_addr32[1] ||
-		    addr.s6_addr32[2] || addr.s6_addr32[3])
+		if (!ipv6_addr_any(&addr))
 			ipv6_dev_ac_inc(ifp->idev->dev, &addr);
 	}
 }
@@ -2368,8 +2366,7 @@
 			struct in6_addr addr;
 
 			ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
-			if (addr.s6_addr32[0] || addr.s6_addr32[1] ||
-			    addr.s6_addr32[2] || addr.s6_addr32[3])
+			if (!ipv6_addr_any(&addr))
 				ipv6_dev_ac_dec(ifp->idev->dev, &addr);
 		}
 		if (!ipv6_chk_addr(&ifp->addr, NULL))

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
