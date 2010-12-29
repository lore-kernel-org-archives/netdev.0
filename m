From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] starfire: Fix dma_addr_t size test for MIPS
Date: Wed, 29 Dec 2010 14:26:17 +0000
Message-ID: <1293632777.2928.127.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Ion Badulescu <ionut@badula.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37094 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752925Ab0L2O0a convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Dec 2010 09:26:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 56543af "starfire: use BUILD_BUG_ON for netdrv_addr_t" revealed
that the preprocessor condition used to find the size of dma_addr_t
yielded the wrong result for some architectures and configurations.
This was kluged for 64-bit PowerPC in commit 3e502e6 by adding yet
another case to the condition.  However, 64-bit MIPS configurations
are not detected reliably either.

This should be fixed by using CONFIG_ARCH_DMA_ADDR_T_64BIT, but that
isn't yet defined everywhere it should be.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
The MIPS conditions are changed to match those Tomonori specified for
CONFIG_ARCH_DMA_ADDR_T_64BIT.

Please change the condition to defined(CONFIG_ARCH_DMA_ADDR_T_64BIT) in
net-next-2.6.  I leave it up to you to decide when to make that change.
(Simply applying a patch to net-next-2.6 now will result in a later
merge conflict and breakage for those two architectures.)

Ben.

 drivers/net/starfire.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 4adf124..a4f2bd5 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -148,7 +148,7 @@ static int full_duplex[MAX_UNITS] = {0, };
  * This SUCKS.
  * We need a much better method to determine if dma_addr_t is 64-bit.
  */
-#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR)) || (defined(__powerpc64__) || defined(CONFIG_PHYS_64BIT))
+#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || (defined(CONFIG_MIPS) && ((defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR)) || defined(CONFIG_64BIT))) || (defined(__powerpc64__) || defined(CONFIG_PHYS_64BIT))
 /* 64-bit dma_addr_t */
 #define ADDR_64BITS	/* This chip uses 64 bit addresses. */
 #define netdrv_addr_t __le64
-- 
1.7.2.3


