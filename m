From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] skb align patch
Date: Sun, 20 Sep 2009 14:22:12 -0700
Message-ID: <20090920142212.1106d2a1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40664 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbZITVWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 17:22:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the Intel suggestion that PCI-express overhead is
a significant cost.

Would people doing performance please measure the impact of
changing SKB alignment (64 bit only).


--- a/arch/x86/include/asm/system.h	2009-09-20 14:08:40.922346912 -0700
+++ b/arch/x86/include/asm/system.h	2009-09-20 14:14:37.012371200 -0700
@@ -455,4 +455,14 @@ static inline void rdtsc_barrier(void)
 	alternative(ASM_NOP3, "lfence", X86_FEATURE_LFENCE_RDTSC);
 }
 
+#ifndef CONFIG_X86_32
+/*
+ * DMA to unaligned address is more expensive than the the
+ * overhead of unaligned CPU access.
+ */
+#define NET_IP_ALIGN	0
+#define NET_SKB_PAD	L1_CACHE_BYTES
+#endif
+
+
 #endif /* _ASM_X86_SYSTEM_H */
