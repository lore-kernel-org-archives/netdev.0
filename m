From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Garbage scope-id in MSG_ERRQUEUE message
Date: Sat, 26 Oct 2002 11:28:13 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021026.112813.43505001.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This patch clears sin6_scope_id in sockaddr_in6 in MSG_ERRQUEUE
message.  Without this we would see garbage there.

This patch is against linux-2.4.20-pre11.

Thanks in advance.

-------------------------------------------------------------------
Patch-Name: Garbage scope-id in MSG_ERRQUEUE message
Patch-Id: FIX_2_4_20_pre11_ICMP_ERROR-20021026
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Credit: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
-------------------------------------------------------------------
Index: net/ipv6/datagram.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/datagram.c,v
retrieving revision 1.1.1.2
retrieving revision 1.1.1.2.22.1
diff -u -r1.1.1.2 -r1.1.1.2.22.1
--- net/ipv6/datagram.c	9 Oct 2002 01:35:53 -0000	1.1.1.2
+++ net/ipv6/datagram.c	25 Oct 2002 16:55:56 -0000	1.1.1.2.22.1
@@ -158,6 +158,7 @@
 	if (serr->ee.ee_origin != SO_EE_ORIGIN_LOCAL) {
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
+		sin->sin6_scope_id = 0;
 		if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP6) {
 			memcpy(&sin->sin6_addr, &skb->nh.ipv6h->saddr, 16);
 			if (sk->net_pinfo.af_inet6.rxopt.all)
