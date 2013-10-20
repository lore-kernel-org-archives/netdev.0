From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 5/9] bnx2x: Fix config when SR-IOV and iSCSI are
 enabled
Date: Sun, 20 Oct 2013 16:51:30 +0200
Message-ID: <1382280694-8428-6-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3402 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328Ab3JTOwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:52:00 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Starting with commit b9871bc "bnx2x: VF RSS support - PF side", if a PF will
have SR-IOV supported in its PCI configuration space, storage drivers will not
work for that interface.

This patch fixes the resource calculation to allow such a configuration to
properly work.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 986edbf..275b126 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1197,8 +1197,9 @@ union cdu_context {
 /* TM (timers) host DB constants */
 #define TM_ILT_PAGE_SZ_HW	0
 #define TM_ILT_PAGE_SZ		(4096 << TM_ILT_PAGE_SZ_HW) /* 4K */
-/* #define TM_CONN_NUM		(CNIC_STARTING_CID+CNIC_ISCSI_CXT_MAX) */
-#define TM_CONN_NUM		1024
+#define TM_CONN_NUM		(BNX2X_FIRST_VF_CID + \
+				 BNX2X_VF_CIDS + \
+				 CNIC_ISCSI_CID_MAX)
 #define TM_ILT_SZ		(8 * TM_CONN_NUM)
 #define TM_ILT_LINES		DIV_ROUND_UP(TM_ILT_SZ, TM_ILT_PAGE_SZ)
 
-- 
1.8.1.227.g44fe835
