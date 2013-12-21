From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] bna: fix sparse non static symbol warnings
Date: Sat, 21 Dec 2013 16:40:55 +0800
Message-ID: <CAPgLHd_dx9YdxMrrCybiEovXCfuGGg0TE+rvap3XpmyezuO+wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:41588 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab3LUIk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 03:40:56 -0500
Received: by mail-bk0-f45.google.com with SMTP id mx13so1483666bkb.4
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 00:40:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warnings:

drivers/net/ethernet/brocade/bna/bnad.c:2112:1: warning:
 symbol 'bnad_reinit_rx' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bfa_ioc.c:1784:1: warning:
 symbol 'bfa_nw_ioc_flash_img_get_size' was not declared. Should it be static?
drivers/net/ethernet/brocade/bna/bfa_ioc.c:1792:1: warning:
 symbol 'bfa_nw_ioc_flash_img_get_chnk' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/brocade/bna/bnad.c    | 2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index d31524f..c3c1cde 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2108,7 +2108,7 @@ bnad_rx_ctrl_init(struct bnad *bnad, u32 rx_id)
 }
 
 /* Called with mutex_lock(&bnad->conf_mutex) held */
-u32
+static u32
 bnad_reinit_rx(struct bnad *bnad)
 {
 	struct net_device *netdev = bnad->netdev;

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 537bba1..4a1f49c 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1780,7 +1780,7 @@ bfa_flash_raw_read(void __iomem *pci_bar, u32 offset, char *buf,
 	return BFA_STATUS_OK;
 }
 
-u32
+static u32
 bfa_nw_ioc_flash_img_get_size(struct bfa_ioc *ioc)
 {
 	return BFI_FLASH_IMAGE_SZ/sizeof(u32);
@@ -1788,7 +1788,7 @@ bfa_nw_ioc_flash_img_get_size(struct bfa_ioc *ioc)
 
 #define BFA_FLASH_PART_FWIMG_ADDR	0x100000 /* fw image address */
 
-enum bfa_status
+static enum bfa_status
 bfa_nw_ioc_flash_img_get_chnk(struct bfa_ioc *ioc, u32 off,
 			      u32 *fwimg)
 {
@@ -2053,7 +2053,7 @@ bfa_ioc_download_fw(struct bfa_ioc *ioc, u32 boot_type,
 
 	if (boot_env == BFI_FWBOOT_ENV_OS &&
 	    boot_type == BFI_FWBOOT_TYPE_FLASH) {
-		fwimg_size = BFI_FLASH_IMAGE_SZ/sizeof(u32);
+		fwimg_size = bfa_nw_ioc_flash_img_get_size(ioc);
 
 		status = bfa_nw_ioc_flash_img_get_chnk(ioc,
 			BFA_IOC_FLASH_CHUNK_ADDR(chunkno), fwimg_buf);
