From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 2/6 v9] sctp: Allow regular C expression in 4th argument for SCTP_DEBUG_PRINTK_IPADDR macro.
Date: Thu, 2 Jun 2011 12:01:17 +0900
Message-ID: <9FF73D2B-4FBE-4BE6-9E84-3B7A4E0CA622@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:49910 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759478Ab1FBDBS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 23:01:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 48390815413c0dac1b39868dd7e874b351848322 Mon Sep 17 00:00:00 2001
From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 26 Apr 2011 19:23:24 +0900
Subject: [PATCH 2/6 v9] sctp: Allow regular C expression in 4th argument for SCTP_DEBUG_PRINTK_IPADDR macro.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/sctp/sctp.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index b2c2366..0037e28 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -285,20 +285,21 @@ do {							\
 		pr_cont(fmt, ##args);			\
 } while (0)
 #define SCTP_DEBUG_PRINTK_IPADDR(fmt_lead, fmt_trail,			\
-				 args_lead, saddr, args_trail...)	\
+				 args_lead, addr, args_trail...)	\
 do {									\
+	const union sctp_addr *_addr = (addr);				\
 	if (sctp_debug_flag) {						\
-		if (saddr->sa.sa_family == AF_INET6) {			\
+		if (_addr->sa.sa_family == AF_INET6) {			\
 			printk(KERN_DEBUG				\
 			       pr_fmt(fmt_lead "%pI6" fmt_trail),	\
 			       args_lead,				\
-			       &saddr->v6.sin6_addr,			\
+			       &_addr->v6.sin6_addr,			\
 			       args_trail);				\
 		} else {						\
 			printk(KERN_DEBUG				\
 			       pr_fmt(fmt_lead "%pI4" fmt_trail),	\
 			       args_lead,				\
-			       &saddr->v4.sin_addr.s_addr,		\
+			       &_addr->v4.sin_addr.s_addr,		\
 			       args_trail);				\
 		}							\
 	}								\
-- 
1.7.3.2


