From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 2/5] bnx2x: save cycles in setting gso_size
Date: Mon, 11 Oct 2010 00:27:55 +0200
Message-ID: <1286749675.4669.24.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2918 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab0JJWcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 18:32:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

the field needs to be set to ANY non-zero value in order to enable forwarding.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index cb2a3d6..ddf90e1 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -277,8 +277,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 	/* This is needed in order to enable forwarding support */
 	if (frag_size)
-		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
-					       max(frag_size, (u32)len_on_bd));
+		skb_shinfo(skb)->gso_size = 1;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (pages > min_t(u32, 8, MAX_SKB_FRAGS)*SGE_PAGE_SIZE*PAGES_PER_SGE) {
-- 
1.7.1




