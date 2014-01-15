From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bnad: code cleanup
Date: Wed, 15 Jan 2014 08:24:21 -0800
Message-ID: <20140115082421.5d2fdfc3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:57887 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaAOQYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:24:24 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so1311927pdi.7
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:24:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use 'make namespacecheck' to code that could be declared static.
After that remove code that is not being used.

Compile tested only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c |   27 +--------------------------
 drivers/net/ethernet/brocade/bna/bnad.c    |    2 +-
 2 files changed, 2 insertions(+), 27 deletions(-)

--- a/drivers/net/ethernet/brocade/bna/bnad.c	2014-01-14 09:46:15.261710097 -0800
+++ b/drivers/net/ethernet/brocade/bna/bnad.c	2014-01-14 09:47:43.800754593 -0800
@@ -2108,7 +2108,7 @@ bnad_rx_ctrl_init(struct bnad *bnad, u32
 }
 
 /* Called with mutex_lock(&bnad->conf_mutex) held */
-u32
+static u32
 bnad_reinit_rx(struct bnad *bnad)
 {
 	struct net_device *netdev = bnad->netdev;
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c	2014-01-14 09:46:15.261710097 -0800
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c	2014-01-14 09:47:43.800754593 -0800
@@ -1147,25 +1147,6 @@ bfa_nw_ioc_sem_release(void __iomem *sem
 	writel(1, sem_reg);
 }
 
-/* Invalidate fwver signature */
-enum bfa_status
-bfa_nw_ioc_fwsig_invalidate(struct bfa_ioc *ioc)
-{
-	u32	pgnum, pgoff;
-	u32	loff = 0;
-	enum bfi_ioc_state ioc_fwstate;
-
-	ioc_fwstate = bfa_ioc_get_cur_ioc_fwstate(ioc);
-	if (!bfa_ioc_state_disabled(ioc_fwstate))
-		return BFA_STATUS_ADAPTER_ENABLED;
-
-	pgnum = bfa_ioc_smem_pgnum(ioc, loff);
-	pgoff = PSS_SMEM_PGOFF(loff);
-	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
-	writel(BFI_IOC_FW_INV_SIGN, ioc->ioc_regs.smem_page_start + loff);
-	return BFA_STATUS_OK;
-}
-
 /* Clear fwver hdr */
 static void
 bfa_ioc_fwver_clear(struct bfa_ioc *ioc)
@@ -1780,15 +1761,9 @@ bfa_flash_raw_read(void __iomem *pci_bar
 	return BFA_STATUS_OK;
 }
 
-u32
-bfa_nw_ioc_flash_img_get_size(struct bfa_ioc *ioc)
-{
-	return BFI_FLASH_IMAGE_SZ/sizeof(u32);
-}
-
 #define BFA_FLASH_PART_FWIMG_ADDR	0x100000 /* fw image address */
 
-enum bfa_status
+static enum bfa_status
 bfa_nw_ioc_flash_img_get_chnk(struct bfa_ioc *ioc, u32 off,
 			      u32 *fwimg)
 {
