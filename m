From: "Michael Chan" <mchan@broadcom.com>
Subject: [BNX2]: Fix 2nd port's MAC address.
Date: Wed, 24 Jan 2007 21:35:45 -0800
Message-ID: <1169703345.5442.4.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2864 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933214AbXAYEuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 23:50:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix 2nd port's MAC address.

On the 5709, we need to add the proper offset to calculate the shared
memory base address of the 2nd port correctly.  Otherwise, the 2nd
port's MAC address and other information will be the same as the 1st
port.

Update version to 1.5.4.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ca5acc4..953808e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -57,8 +57,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.5.3"
-#define DRV_MODULE_RELDATE	"January 8, 2007"
+#define DRV_MODULE_VERSION	"1.5.4"
+#define DRV_MODULE_RELDATE	"January 24, 2007"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -5845,9 +5845,11 @@ bnx2_init_board(struct pci_dev *pdev, st
 	reg = REG_RD_IND(bp, BNX2_SHM_HDR_SIGNATURE);
 
 	if ((reg & BNX2_SHM_HDR_SIGNATURE_SIG_MASK) ==
-	    BNX2_SHM_HDR_SIGNATURE_SIG)
-		bp->shmem_base = REG_RD_IND(bp, BNX2_SHM_HDR_ADDR_0);
-	else
+	    BNX2_SHM_HDR_SIGNATURE_SIG) {
+		u32 off = PCI_FUNC(pdev->devfn) << 2;
+
+		bp->shmem_base = REG_RD_IND(bp, BNX2_SHM_HDR_ADDR_0 + off);
+	} else
 		bp->shmem_base = HOST_VIEW_SHMEM_BASE;
 
 	/* Get the permanent MAC address.  First we need to make sure the


