From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 2/6 v8] sctp: Allow regular C expression in 4th argument for SCTP_DEBUG_PRINTK_IPADDR macro.
Date: Thu, 28 Apr 2011 11:01:04 +0900
Message-ID: <1133F8D4-6ECB-4131-BECA-336F0320E5C1@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Honda Michio <micchie@sfc.wide.ad.jp>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:48833 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752100Ab1D1CBF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 22:01:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From e535067d5c26223c7230232ee8e228370db113a6 Mon Sep 17 00:00:00 2001
From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 26 Apr 2011 19:23:24 +0900
Subject: [PATCH 2/6 v8] sctp: Allow regular C expression in 4th argument for SCTP_DEBUG_PRINTK_IPADDR macro.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/sctp/sctp.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 7e8e34c..e606f04 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -286,20 +286,21 @@ do {							\
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


