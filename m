From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: fix an oops in rt6_device_match()
Date: Sat, 11 Sep 2004 20:10:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911.201029.21582458.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This fixes panic in rt6_device_match().

Well, rt->rt6i_idev is always set if it is dynamically allocated.
However, when we hit ip6_null_entry here, its rt6i_idev is NULL.
This patch is minimum fix to avoid the oops for now.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/route.c 1.89 vs edited =====
--- 1.89/net/ipv6/route.c	2004-08-25 03:20:43 +09:00
+++ edited/net/ipv6/route.c	2004-09-11 19:31:24 +09:00
@@ -184,7 +184,8 @@
 			if (dev->ifindex == oif)
 				return sprt;
 			if (dev->flags & IFF_LOOPBACK) {
-				if (sprt->rt6i_idev->dev->ifindex != oif) {
+				if (sprt->rt6i_idev == NULL ||
+				    sprt->rt6i_idev->dev->ifindex != oif) {
 					if (strict && oif)
 						continue;
 					if (local && (!oif || 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
