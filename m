From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Fix for Refine IPv6 Address Validation Timer
Date: Sun, 27 Oct 2002 01:10:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021027.011025.86893867.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

We sent a patch to refine timing of IPv6 address validation timer.
However, timer was not recalculated on receipt of RA.
This patch fixes this bug.

Patch is for 2.4.20-pre11.

Thanks.

Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.2
retrieving revision 1.1.1.2.26.1
diff -u -r1.1.1.2 -r1.1.1.2.26.1
--- net/ipv6/addrconf.c	9 Oct 2002 01:35:53 -0000	1.1.1.2
+++ net/ipv6/addrconf.c	26 Oct 2002 15:55:14 -0000	1.1.1.2.26.1
@@ -947,6 +947,7 @@
 				ipv6_ifa_notify((flags&IFA_F_DEPRECATED) ?
 						0 : RTM_NEWADDR, ifp);
 			in6_ifa_put(ifp);
+			addrconf_verify(0);
 		}
 	}
 	in6_dev_put(in6_dev);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
