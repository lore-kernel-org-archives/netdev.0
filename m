From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: fix compilation
Date: Thu, 13 Sep 2007 19:23:33 +0400
Message-ID: <20070913152333.GA2381@localhost.localdomain>
References: <20070912112456.GA15556@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:4976 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750922AbXIMPUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 11:20:35 -0400
Content-Disposition: inline
In-Reply-To: <20070912112456.GA15556@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently qe_bd_t is used in the macro call -- dma_unmap_single,
which is a no-op on PPC32, thus error is hidden today. Starting
with 2.6.24, macro will be replaced by the empty static function,
and erroneous use of qe_bd_t will trigger compilation error.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

Reposting this to include netdev in Cc.

 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e01b2..9a38dfe 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2148,7 +2148,7 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
 				dma_unmap_single(NULL,
-						 ((qe_bd_t *)bd)->buf,
+						 ((struct qe_bd *)bd)->buf,
 						 (in_be32((u32 *)bd) &
 						  BD_LENGTH_MASK),
 						 DMA_TO_DEVICE);
-- 
1.5.0.6
