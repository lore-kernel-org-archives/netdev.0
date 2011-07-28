From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 1/2] bna: Remove Unnecessary CNA Check
Date: Thu, 28 Jul 2011 14:49:26 -0700
Message-ID: <1311889767-9848-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55843 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755070Ab1G1Vtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 17:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - ioc->cna is always set to 1 for eth functions, remove the check that
   asserts IOC is in CNA mode in bfa_ioc_firmware_lock() and
   bfa_ioc_firmware_unlock() in bfa_ioc_ct.c.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc_ct.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/bna/bfa_ioc_ct.c
index 87aecdf..c43f942 100644
--- a/drivers/net/bna/bfa_ioc_ct.c
+++ b/drivers/net/bna/bfa_ioc_ct.c
@@ -84,12 +84,6 @@ bfa_ioc_ct_firmware_lock(struct bfa_ioc *ioc)
 	struct bfi_ioc_image_hdr fwhdr;
 
 	/**
-	 * Firmware match check is relevant only for CNA.
-	 */
-	if (!ioc->cna)
-		return true;
-
-	/**
 	 * If bios boot (flash based) -- do not increment usage count
 	 */
 	if (bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(ioc)) <
@@ -140,12 +134,6 @@ bfa_ioc_ct_firmware_unlock(struct bfa_ioc *ioc)
 	u32 usecnt;
 
 	/**
-	 * Firmware lock is relevant only for CNA.
-	 */
-	if (!ioc->cna)
-		return;
-
-	/**
 	 * If bios boot (flash based) -- do not decrement usage count
 	 */
 	if (bfa_cb_image_get_size(BFA_IOC_FWIMG_TYPE(ioc)) <
-- 
1.7.1

