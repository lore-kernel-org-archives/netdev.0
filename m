From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] MACB: Use __raw register access
Date: Fri, 8 Dec 2006 14:38:30 +0100
Message-ID: <20061208143830.092e3a32@dhcp-252-105.norway.atmel.com>
References: <20061208143735.7050553a@dhcp-252-105.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Andrew Victor <andrew@sanpeople.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:60439 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759646AbWLHNiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 08:38:55 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061208143735.7050553a@dhcp-252-105.norway.atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since macb is a chip-internal device, use __raw_readl and
__raw_writel instead of readl/writel. This will perform native-endian
accesses, which is the right thing to do on both AVR32 and ARM devices.

Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |    2 +-
 drivers/net/macb.h |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 3496d19..25b559b 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -264,7 +264,7 @@ static void macb_update_stats(struct mac
 	WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
 
 	for(; p < end; p++, reg++)
-		*p += readl(reg);
+		*p += __raw_readl(reg);
 }
 
 static void macb_periodic_task(struct work_struct *work)
diff --git a/drivers/net/macb.h b/drivers/net/macb.h
index e3fcb2e..27bf0ae 100644
--- a/drivers/net/macb.h
+++ b/drivers/net/macb.h
@@ -250,9 +250,9 @@
 
 /* Register access macros */
 #define macb_readl(port,reg)				\
-	readl((port)->regs + MACB_##reg)
+	__raw_readl((port)->regs + MACB_##reg)
 #define macb_writel(port,reg,value)			\
-	writel((value), (port)->regs + MACB_##reg)
+	__raw_writel((value), (port)->regs + MACB_##reg)
 
 struct dma_desc {
 	u32	addr;
-- 
1.4.3.3

