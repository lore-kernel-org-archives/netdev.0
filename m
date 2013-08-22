From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/32] sfc: const-qualify source pointers for MMIO
 write functions
Date: Thu, 22 Aug 2013 13:44:47 +0100
Message-ID: <1377175487.1703.7.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13455 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588Ab3HVMov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 08:44:51 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/io.h | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 96759aee..39f6098 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -83,7 +83,7 @@ static inline __le32 _efx_readd(struct efx_nic *efx, unsigned int reg)
 }
 
 /* Write a normal 128-bit CSR, locking as appropriate. */
-static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
+static inline void efx_writeo(struct efx_nic *efx, const efx_oword_t *value,
 			      unsigned int reg)
 {
 	unsigned long flags __attribute__ ((unused));
@@ -108,7 +108,7 @@ static inline void efx_writeo(struct efx_nic *efx, efx_oword_t *value,
 
 /* Write 64-bit SRAM through the supplied mapping, locking as appropriate. */
 static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
-				   efx_qword_t *value, unsigned int index)
+				   const efx_qword_t *value, unsigned int index)
 {
 	unsigned int addr = index * sizeof(*value);
 	unsigned long flags __attribute__ ((unused));
@@ -129,7 +129,7 @@ static inline void efx_sram_writeq(struct efx_nic *efx, void __iomem *membase,
 }
 
 /* Write a 32-bit CSR or the last dword of a special 128-bit CSR */
-static inline void efx_writed(struct efx_nic *efx, efx_dword_t *value,
+static inline void efx_writed(struct efx_nic *efx, const efx_dword_t *value,
 			      unsigned int reg)
 {
 	netif_vdbg(efx, hw, efx->net_dev,
@@ -190,8 +190,9 @@ static inline void efx_readd(struct efx_nic *efx, efx_dword_t *value,
 }
 
 /* Write a 128-bit CSR forming part of a table */
-static inline void efx_writeo_table(struct efx_nic *efx, efx_oword_t *value,
-				      unsigned int reg, unsigned int index)
+static inline void
+efx_writeo_table(struct efx_nic *efx, const efx_oword_t *value,
+		 unsigned int reg, unsigned int index)
 {
 	efx_writeo(efx, value, reg + index * sizeof(efx_oword_t));
 }
@@ -239,8 +240,9 @@ static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,
 /* Write a page-mapped 32-bit CSR (EVQ_RPTR or the high bits of
  * RX_DESC_UPD or TX_DESC_UPD)
  */
-static inline void _efx_writed_page(struct efx_nic *efx, efx_dword_t *value,
-				    unsigned int reg, unsigned int page)
+static inline void
+_efx_writed_page(struct efx_nic *efx, const efx_dword_t *value,
+		 unsigned int reg, unsigned int page)
 {
 	efx_writed(efx, value, EFX_PAGED_REG(page, reg));
 }
@@ -256,7 +258,7 @@ static inline void _efx_writed_page(struct efx_nic *efx, efx_dword_t *value,
  * collector register.
  */
 static inline void _efx_writed_page_locked(struct efx_nic *efx,
-					   efx_dword_t *value,
+					   const efx_dword_t *value,
 					   unsigned int reg,
 					   unsigned int page)
 {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
