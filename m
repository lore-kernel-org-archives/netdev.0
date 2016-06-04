From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] qed: Fix next-ptr chains for BE / 32-bit
Date: Sat, 4 Jun 2016 08:20:16 +0300
Message-ID: <1465017616-3892-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <fengguang.wu@intel.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49919 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbcFDFUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 01:20:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a91eb52abb50 ("qed: Revisit chain implementation") contains an
incorrect implementation for BE platforms, as device's regpairs containing
addresses are LE and they're not converted correctly when read back.
In addition, it raises a compilation warning for 32-bit platforms where
dma_addr_t is a 32-bit variable.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval
---
 include/linux/qed/qed_chain.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/qed/qed_chain.h b/include/linux/qed/qed_chain.h
index eceaa9e..7e441bd 100644
--- a/include/linux/qed/qed_chain.h
+++ b/include/linux/qed/qed_chain.h
@@ -25,10 +25,9 @@
 				} while (0)
 
 #define HILO_GEN(hi, lo, type)  ((((type)(hi)) << 32) + (lo))
-#define HILO_DMA(hi, lo)        HILO_GEN(hi, lo, dma_addr_t)
 #define HILO_64(hi, lo) HILO_GEN((le32_to_cpu(hi)), (le32_to_cpu(lo)), u64)
-#define HILO_DMA_REGPAIR(regpair)       (HILO_DMA(regpair.hi, regpair.lo))
 #define HILO_64_REGPAIR(regpair)        (HILO_64(regpair.hi, regpair.lo))
+#define HILO_DMA_REGPAIR(regpair)	((dma_addr_t)HILO_64_REGPAIR(regpair))
 
 enum qed_chain_mode {
 	/* Each Page contains a next pointer at its end */
-- 
1.9.3
