From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPv6: Fix Length of Authentication Extension Header
Date: Sun, 05 Jan 2003 02:48:23 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030105.024823.61168301.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

This patch fixes calculation of length of IPv6 Authentication Extension
Header.

RFC2402: 2.2 Payload Length
:
This 8-bit field specifies the length of AH in 32-bit words (4-byte
units), minus "2".  ...

This is against linux-2.4.20, 2.5.54. 
(2.2.x series have similar bug, too.)

Thanks in advance.

-------------------------------------------------------------------
Patch-Name: Fix Length of Authentication Extension Header
Patch-Id: FIX_2_4_20_EXTHDRS_AUTHHDRLEN-20030105
Patch-Author: YOSHIFUJI Hideaki / USAGI Project <yoshfuji@linux-ipv6.org>
Credit: Noriaki Takamiya / USAGI Project <takamiya@linux-ipv6.org>
Reference: RFC2402
-------------------------------------------------------------------
Index: net/ipv6/exthdrs.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/exthdrs.c,v
retrieving revision 1.1.1.1
retrieving revision 1.1.1.1.46.1
diff -u -r1.1.1.1 -r1.1.1.1.46.1
--- net/ipv6/exthdrs.c	20 Aug 2002 09:47:02 -0000	1.1.1.1
+++ net/ipv6/exthdrs.c	4 Jan 2003 17:19:03 -0000	1.1.1.1.46.1
@@ -402,7 +402,13 @@
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8))
 		goto fail;
 
-	len = (skb->h.raw[1]+1)<<2;
+	/*
+	 * RFC2402 2.2 Payload Length
+	 * The 8-bit field specifies the length of AH in 32-bit words 
+	 * (4-byte units), minus "2".
+	 * -- Noriaki Takamiya @USAGI Project
+	 */
+	len = (skb->h.raw[1]+2)<<2;
 
 	if (len&7)
 		goto fail;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
