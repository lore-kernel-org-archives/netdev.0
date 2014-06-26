From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/3] bnx2x: enlarge minimal alignemnt of data offset
Date: Thu, 26 Jun 2014 14:31:05 +0300
Message-ID: <1403782266-25362-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1403782266-25362-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:38881 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757460AbaFZLbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 07:31:20 -0400
In-Reply-To: <1403782266-25362-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>

This improves the performance of driver on machine with L1_CACHE_SHIFT of at
most 32 bytes [HW was planned for 64-byte aligned fastpath data].

Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index faf262a..ce8f869 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1508,8 +1508,10 @@ struct bnx2x {
 /* TCP with Timestamp Option (32) + IPv6 (40) */
 #define ETH_MAX_TPA_HEADER_SIZE		72
 
-	/* Max supported alignment is 256 (8 shift) */
-#define BNX2X_RX_ALIGN_SHIFT		min(8, L1_CACHE_SHIFT)
+	/* Max supported alignment is 256 (8 shift)
+	 * minimal alignment shift 6 is optimal for 57xxx HW performance
+	 */
+#define BNX2X_RX_ALIGN_SHIFT		max(6, min(8, L1_CACHE_SHIFT))
 
 	/* FW uses 2 Cache lines Alignment for start packet and size
 	 *
-- 
1.8.3.1
