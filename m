From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Thu, 09 Oct 2008 22:14:26 -0700 (PDT)
Message-ID: <20081009.221426.120533568.davem@davemloft.net>
References: <20081009212755.94fe11f6.akpm@linux-foundation.org>
	<20081009.215452.193703022.davem@davemloft.net>
	<20081009.220513.181546765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36688
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbYJJFOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 01:14:50 -0400
In-Reply-To: <20081009.220513.181546765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just pushed the following into net-next-2.6:

enic: Attempt to fix build in 32-bit such as i386.

Such platforms lack readq/writeq but this driver want to call them.

Noticed by Andrew Morton.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/enic/vnic_dev.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 2dcffd3..b9dc182 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -27,6 +27,20 @@
 #define VNIC_PADDR_TARGET	0x0000000000000000ULL
 #endif
 
+#ifndef readq
+static inline u64 readq(void __iomem *reg)
+{
+	return (((u64)readl(reg + 0x4UL) << 32) |
+		(u64)readl(reg));
+}
+
+static inline void writeq(u64 val, void __iomem *reg)
+{
+	writel(val & 0xffffffff, reg);
+	writel(val >> 32, reg + 0x4UL);
+}
+#endif
+
 enum vnic_dev_intr_mode {
 	VNIC_DEV_INTR_MODE_UNKNOWN,
 	VNIC_DEV_INTR_MODE_INTX,
-- 
1.5.6.5

