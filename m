From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 04/10] sfc: Remove redundant memory barriers
 between MMIOs
Date: Fri, 10 Dec 2010 17:38:30 +0000
Message-ID: <1292002710.11673.18.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26908 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab0LJRie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:38:34 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/io.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/io.h b/drivers/net/sfc/io.h
index 0764e84..896b31e 100644
--- a/drivers/net/sfc/io.h
+++ b/drivers/net/sfc/io.h
@@ -96,13 +96,11 @@ static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 	spin_lock_irqsave(&efx->biu_lock, flags);
 #ifdef EFX_USE_QWORD_IO
 	_efx_writeq(efx, value->u64[0], reg + 0);
-	wmb();
 	_efx_writeq(efx, value->u64[1], reg + 8);
 #else
 	_efx_writed(efx, value->u32[0], reg + 0);
 	_efx_writed(efx, value->u32[1], reg + 4);
 	_efx_writed(efx, value->u32[2], reg + 8);
-	wmb();
 	_efx_writed(efx, value->u32[3], reg + 12);
 #endif
 	mmiowb();
@@ -125,7 +123,6 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 	__raw_writeq((__force u64)value->u64[0], membase + addr);
 #else
 	__raw_writel((__force u32)value->u32[0], membase + addr);
-	wmb();
 	__raw_writel((__force u32)value->u32[1], membase + addr + 4);
 #endif
 	mmiowb();
@@ -152,7 +149,6 @@ static inline void efx_reado(struct efx_nic *efx, efx_oword_t *value,
 
 	spin_lock_irqsave(&efx->biu_lock, flags);
 	value->u32[0] = _efx_readd(efx, reg + 0);
-	rmb();
 	value->u32[1] = _efx_readd(efx, reg + 4);
 	value->u32[2] = _efx_readd(efx, reg + 8);
 	value->u32[3] = _efx_readd(efx, reg + 12);
@@ -175,7 +171,6 @@ static inline void efx_sram_readq(struct efx_nic *efx, void __iomem *membase,
 	value->u64[0] = (__force __le64)__raw_readq(membase + addr);
 #else
 	value->u32[0] = (__force __le32)__raw_readl(membase + addr);
-	rmb();
 	value->u32[1] = (__force __le32)__raw_readl(membase + addr + 4);
 #endif
 	spin_unlock_irqrestore(&efx->biu_lock, flags);
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

