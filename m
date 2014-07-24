From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fixed incorrect check for memory operation in t4_memory_rw
Date: Thu, 24 Jul 2014 17:16:30 +0530
Message-ID: <1406202390-23012-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:39921
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750771AbaGXLkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 07:40:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrect check introduced in commit fc5ab020 ("cxgb4: Replaced the
backdoor mechanism to access the HW memory with PCIe Window method"). We where
checking for write operation and doing a read, changed it accordingly.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 9779a69..23fa0e1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -545,7 +545,7 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 		unsigned char *bp;
 		int i;
 
-		if (dir == T4_MEMORY_WRITE) {
+		if (dir == T4_MEMORY_READ) {
 			last.word = (__force __be32) t4_read_reg(adap,
 							mem_base + offset);
 			for (bp = (unsigned char *)buf, i = resid; i < 4; i++)
-- 
1.7.1
