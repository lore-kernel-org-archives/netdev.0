From: frank.blaschka@de.ibm.com
Subject: [patch 3/7] [PATCH] net,s390: provide architecture specific NET_SKB_PAD
Date: Tue, 01 Feb 2011 09:16:50 +0100
Message-ID: <20110201081723.562745244@de.ibm.com>
References: <20110201081647.173934635@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Horst Hartmann <horsth@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:46131 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab1BAISg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 03:18:36 -0500
Content-Disposition: inline; filename=606-net-skb-pad.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Horst Hartmann <horsth@linux.vnet.ibm.com>

NET_SKB_PAD has been increased from 32 to 64 and later to max(32, L1_CACHE_BYTES). 
This led to a 25% throughput decrease for streaming workloads accompanied by a                                                               
37% CPU cost increase on s390.
In order to fix this provide an architecture specific NET_SKB_PAD config symbol.

Signed-off-by: Horst Hartmann <horsth@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 arch/s390/Kconfig      |    4 ++++
 include/linux/skbuff.h |    4 +++-
 2 files changed, 7 insertions(+), 1 deletion(-)
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -49,6 +49,10 @@ config NO_DMA
 config ARCH_DMA_ADDR_T_64BIT
 	def_bool 64BIT
 
+config NET_SKB_PAD
+	int
+	default "32"
+
 config GENERIC_LOCKBREAK
 	def_bool y if SMP && PREEMPT
 
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1431,8 +1431,10 @@ static inline int pskb_network_may_pull(
  * get_rps_cpus() for example only access one 64 bytes aligned block :
  * NET_IP_ALIGN(2) + ethernet_header(14) + IP_header(20/40) + ports(8)
  */
-#ifndef NET_SKB_PAD
+#ifndef CONFIG_NET_SKB_PAD
 #define NET_SKB_PAD	max(32, L1_CACHE_BYTES)
+#else
+#define NET_SKB_PAD	CONFIG_NET_SKB_PAD
 #endif
 
 extern int ___pskb_trim(struct sk_buff *skb, unsigned int len);

