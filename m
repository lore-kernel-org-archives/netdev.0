From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: fix a mistake in ipv6_advmss() conversion
Date: Thu, 03 Jul 2003 02:55:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030703.025529.100658086.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Sorry, I introduced a bug in ipv6_advmss()
while converting advmss calculation to inline function.
This patch fixes the bug.

Index: linux-2.5/net/ipv6/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/route.c,v
retrieving revision 1.43
diff -u -r1.43 route.c
--- linux-2.5/net/ipv6/route.c	28 Jun 2003 03:58:20 -0000	1.43
+++ linux-2.5/net/ipv6/route.c	2 Jul 2003 16:25:04 -0000
@@ -602,6 +602,8 @@
 
 static inline unsigned int ipv6_advmss(unsigned int mtu)
 {
+	mtu -= sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
+
 	if (mtu < ip6_rt_min_advmss)
 		mtu = ip6_rt_min_advmss;
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
