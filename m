From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] starfire: clean up dma_addr_t size test
Date: Sat, 2 Apr 2011 00:27:51 +0900
Message-ID: <20110402002600P.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:37200 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757957Ab1DAP1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 11:27:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only compile tested.

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] starfire: clean up dma_addr_t size test

Now we have CONFIG_ARCH_DMA_ADDR_T_64BIT. We can fix the hacky
dma_addr_t size test cleanly.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/starfire.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index a4f2bd5..36045f3 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -144,11 +144,7 @@ static int full_duplex[MAX_UNITS] = {0, };
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(2 * HZ)
 
-/*
- * This SUCKS.
- * We need a much better method to determine if dma_addr_t is 64-bit.
- */
-#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || (defined(CONFIG_MIPS) && ((defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR)) || defined(CONFIG_64BIT))) || (defined(__powerpc64__) || defined(CONFIG_PHYS_64BIT))
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 /* 64-bit dma_addr_t */
 #define ADDR_64BITS	/* This chip uses 64 bit addresses. */
 #define netdrv_addr_t __le64
-- 
1.7.2.3

