From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 11/11] Removing dead REDWOOD_{5,6}
Date: Wed, 14 Jul 2010 14:41:31 +0200
Message-ID: <adba61f63f4439ac17f2e428429f01ae5e65ab15.1279110895.git.siccegge__44978.1224983328$1279111337$gmane$org@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>,
	Daniel Walker <dwalker@codeaurora.org>,
	Alessandro Rubini <rubini@unipv.i
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43714 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756872Ab0GNMld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:41:33 -0400
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

REDWOOD_{5,6} doesn't exist in Kconfig, therefore removing all
references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/smc91x.h |   37 -------------------------------------
 1 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 8d2772c..ee74791 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -83,43 +83,6 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 	}
 }
 
-#elif defined(CONFIG_REDWOOD_5) || defined(CONFIG_REDWOOD_6)
-
-/* We can only do 16-bit reads and writes in the static memory space. */
-#define SMC_CAN_USE_8BIT	0
-#define SMC_CAN_USE_16BIT	1
-#define SMC_CAN_USE_32BIT	0
-#define SMC_NOWAIT		1
-
-#define SMC_IO_SHIFT		0
-
-#define SMC_inw(a, r)		in_be16((volatile u16 *)((a) + (r)))
-#define SMC_outw(v, a, r)	out_be16((volatile u16 *)((a) + (r)), v)
-#define SMC_insw(a, r, p, l) 						\
-	do {								\
-		unsigned long __port = (a) + (r);			\
-		u16 *__p = (u16 *)(p);					\
-		int __l = (l);						\
-		insw(__port, __p, __l);					\
-		while (__l > 0) {					\
-			*__p = swab16(*__p);				\
-			__p++;						\
-			__l--;						\
-		}							\
-	} while (0)
-#define SMC_outsw(a, r, p, l) 						\
-	do {								\
-		unsigned long __port = (a) + (r);			\
-		u16 *__p = (u16 *)(p);					\
-		int __l = (l);						\
-		while (__l > 0) {					\
-			/* Believe it or not, the swab isn't needed. */	\
-			outw( /* swab16 */ (*__p++), __port);		\
-			__l--;						\
-		}							\
-	} while (0)
-#define SMC_IRQ_FLAGS		(0)
-
 #elif defined(CONFIG_SA1100_PLEB)
 /* We can only do 16-bit reads and writes in the static memory space. */
 #define SMC_CAN_USE_8BIT	1
-- 
1.7.0.4

