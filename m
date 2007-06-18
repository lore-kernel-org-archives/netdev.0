From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] [IPV6]: Make IPV6_{RECV,2292}RTHDR boolean options.
Date: Mon, 18 Jun 2007 15:06:08 +0900 (JST)
Message-ID: <20070618.150608.70490966.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40402 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbXFRGFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 02:05:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because reversing RH0 is no longer supported by deprecation
of RH0, let's make IPV6_{RECV,2292}RTHDR boolean options.
Boolean are more appropriate from standard POV.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h     |    4 ++--
 net/ipv6/ipv6_sockglue.c |    8 ++------
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2cfbe9a..0b1febb 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -299,8 +299,8 @@ struct ipv6_pinfo {
 	/* pktoption flags */
 	union {
 		struct {
-			__u16	srcrt:2,
-				osrcrt:2,
+			__u16	srcrt:1,
+				osrcrt:1,
 			        rxinfo:1,
 			        rxoinfo:1,
 				rxhlim:1,
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index f66ce0c..b5c0754 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -336,16 +336,12 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		break;
 
 	case IPV6_RECVRTHDR:
-		if (val < 0 || val > 2)
-			goto e_inval;
-		np->rxopt.bits.srcrt = val;
+		np->rxopt.bits.srcrt = valbool;
 		retv = 0;
 		break;
 
 	case IPV6_2292RTHDR:
-		if (val < 0 || val > 2)
-			goto e_inval;
-		np->rxopt.bits.osrcrt = val;
+		np->rxopt.bits.osrcrt = valbool;
 		retv = 0;
 		break;
 
-- 
1.5.1

