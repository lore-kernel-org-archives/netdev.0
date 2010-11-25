From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Use skb_is_gso_v6(skb) instead of
 accessing the skb_shinfo(skb) directly
Date: Thu, 25 Nov 2010 11:52:42 +0200
Message-ID: <1290678762.18389.1.camel@lb-tlvb-vladz>
References: <1290612078.27220.2.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2470 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750997Ab0KYJxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Nov 2010 04:53:02 -0500
In-Reply-To: <1290612078.27220.2.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 94d5f59..fa8e9ee 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1695,7 +1695,7 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
 		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
 
-	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+	else if (skb_is_gso_v6(skb))
 		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
 
 	return rc;
-- 
1.7.0.4




