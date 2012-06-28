From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] cnic: Remove uio mem[0].
Date: Wed, 27 Jun 2012 18:08:21 -0700
Message-ID: <1340845704-12580-3-git-send-email-mchan@broadcom.com>
References: <1340845704-12580-1-git-send-email-mchan@broadcom.com>
 <1340845704-12580-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3193 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184Ab2F1A50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 20:57:26 -0400
In-Reply-To: <1340845704-12580-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This memory region is no longer used.  Userspace gets the BAR address
directly from sysfs.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 5980443..ec43df1 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1063,10 +1063,7 @@ static int cnic_init_uio(struct cnic_dev *dev)
 
 	uinfo = &udev->cnic_uinfo;
 
-	uinfo->mem[0].addr = dev->netdev->base_addr;
-	uinfo->mem[0].internal_addr = dev->regview;
-	uinfo->mem[0].size = dev->netdev->mem_end - dev->netdev->mem_start;
-	uinfo->mem[0].memtype = UIO_MEM_PHYS;
+	uinfo->mem[0].memtype = UIO_MEM_NONE;
 
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		uinfo->mem[1].addr = (unsigned long) cp->status_blk.gen &
-- 
1.7.1
