From: Cyril Roelandt <tipecaml@gmail.com>
Subject: [PATCH 1/6] bna: remove useless calls to memset().
Date: Sun,  2 Dec 2012 03:40:17 +0100
Message-ID: <1354416022-20189-2-git-send-email-tipecaml@gmail.com>
References: <1354416022-20189-1-git-send-email-tipecaml@gmail.com>
Cc: kernel-janitors@vger.kernel.org,
	Cyril Roelandt <tipecaml@gmail.com>, rmody@brocade.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64715 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab2LBCrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 21:47:21 -0500
In-Reply-To: <1354416022-20189-1-git-send-email-tipecaml@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These calls are followed by calls to memcpy() on the same memory area, so they
can safely be removed.

Signed-off-by: Cyril Roelandt <tipecaml@gmail.com>
---
 drivers/net/ethernet/brocade/bna/bfa_ioc.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 959c58e..3227fdd 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -2273,7 +2273,6 @@ bfa_ioc_get_type(struct bfa_ioc *ioc)
 static void
 bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num)
 {
-	memset(serial_num, 0, BFA_ADAPTER_SERIAL_NUM_LEN);
 	memcpy(serial_num,
 			(void *)ioc->attr->brcd_serialnum,
 			BFA_ADAPTER_SERIAL_NUM_LEN);
@@ -2282,7 +2281,6 @@ bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num)
 static void
 bfa_ioc_get_adapter_fw_ver(struct bfa_ioc *ioc, char *fw_ver)
 {
-	memset(fw_ver, 0, BFA_VERSION_LEN);
 	memcpy(fw_ver, ioc->attr->fw_version, BFA_VERSION_LEN);
 }
 
@@ -2304,7 +2302,6 @@ bfa_ioc_get_pci_chip_rev(struct bfa_ioc *ioc, char *chip_rev)
 static void
 bfa_ioc_get_adapter_optrom_ver(struct bfa_ioc *ioc, char *optrom_ver)
 {
-	memset(optrom_ver, 0, BFA_VERSION_LEN);
 	memcpy(optrom_ver, ioc->attr->optrom_version,
 		      BFA_VERSION_LEN);
 }
@@ -2312,7 +2309,6 @@ bfa_ioc_get_adapter_optrom_ver(struct bfa_ioc *ioc, char *optrom_ver)
 static void
 bfa_ioc_get_adapter_manufacturer(struct bfa_ioc *ioc, char *manufacturer)
 {
-	memset(manufacturer, 0, BFA_ADAPTER_MFG_NAME_LEN);
 	memcpy(manufacturer, BFA_MFG_NAME, BFA_ADAPTER_MFG_NAME_LEN);
 }
 
-- 
1.7.10.4
