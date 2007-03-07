From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH] NETLINK: convert NLMSG_GOODSIZE to constant expression.
Date: Wed, 07 Mar 2007 16:34:01 +0900 (JST)
Message-ID: <20070307.163401.110957772.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34392 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161347AbXCGHeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 02:34:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the following error:
:
|  CC [M]  net/ipv4/netfilter/ipt_ULOG.o
|net/ipv4/netfilter/ipt_ULOG.c:82: error: braced-group within expression allowed only inside a function
|net/ipv4/netfilter/ipt_ULOG.c:82: error: syntax error before "void"
|make[1]: *** [net/ipv4/netfilter/ipt_ULOG.o] Error 1
|make: *** [net/ipv4/netfilter/] Error 2

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 54597e4..a9d3ad5 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -175,8 +175,12 @@ int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol);
  *	use enormous buffer sizes on recvmsg() calls just to avoid
  *	MSG_TRUNC when PAGE_SIZE is very large.
  */
-#define NLMSG_GOODSIZE	\
-	SKB_WITH_OVERHEAD(min(PAGE_SIZE,8192UL))
+#if PAGE_SIZE < 8192UL
+#define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(PAGE_SIZE)
+#else
+#define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
+#endif
+
 #define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
 
 

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
