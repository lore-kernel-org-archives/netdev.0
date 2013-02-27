From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net] bnx2x: fix UDP checksum for 57710/57711.
Date: Wed, 27 Feb 2013 12:04:59 +0200
Message-ID: <1361959499-3968-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3033 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213Ab3B0KFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 05:05:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 86564c3f "bnx2x: Remove many sparse warnings" UDP
csum offload is broken for 57710/57711. Fix return value.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
CC: Ariel Elior <ariele@broadcom.com>
CC: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ecac04a3..a923bc4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3142,7 +3142,7 @@ static inline __le16 bnx2x_csum_fix(unsigned char *t_header, u16 csum, s8 fix)
 		tsum = ~csum_fold(csum_add((__force __wsum) csum,
 				  csum_partial(t_header, -fix, 0)));
 
-	return bswab16(csum);
+	return bswab16(tsum);
 }
 
 static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
-- 
1.7.7.2
