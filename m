From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4 net-next] bnx2: Fix endian swapping on firmware
 version string
Date: Wed, 20 Jul 2011 17:55:25 -0700
Message-ID: <1311209725-10414-4-git-send-email-mchan@broadcom.com>
References: <1311209725-10414-1-git-send-email-mchan@broadcom.com>
 <1311209725-10414-2-git-send-email-mchan@broadcom.com>
 <1311209725-10414-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3030 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839Ab1GUBre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 21:47:34 -0400
In-Reply-To: <1311209725-10414-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so that ethtool -i will display it correctly on big endian systems.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 3ad9b70..4b2b570 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 #include "bnx2_fw.h"
 
 #define DRV_MODULE_NAME		"bnx2"
-#define DRV_MODULE_VERSION	"2.1.10"
-#define DRV_MODULE_RELDATE	"July 12, 2011"
+#define DRV_MODULE_VERSION	"2.1.11"
+#define DRV_MODULE_RELDATE	"July 20, 2011"
 #define FW_MIPS_FILE_06		"bnx2/bnx2-mips-06-6.2.1.fw"
 #define FW_RV2P_FILE_06		"bnx2/bnx2-rv2p-06-6.0.15.fw"
 #define FW_MIPS_FILE_09		"bnx2/bnx2-mips-09-6.2.1a.fw"
@@ -8097,7 +8097,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			bp->fw_version[j++] = ' ';
 		for (i = 0; i < 3 && j < 28; i++) {
 			reg = bnx2_reg_rd_ind(bp, addr + i * 4);
-			reg = swab32(reg);
+			reg = be32_to_cpu(reg);
 			memcpy(&bp->fw_version[j], &reg, 4);
 			j += 4;
 		}
-- 
1.6.4.GIT


