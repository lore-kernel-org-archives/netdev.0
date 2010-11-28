From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Use helpers instead of direct access to
 the shinfo(skb) fields
Date: Sun, 28 Nov 2010 12:23:35 +0200
Message-ID: <1290939815.21703.81.camel@lb-tlvb-vladz>
References: <1290612078.27220.2.camel@lb-tlvb-vladz>
 <1290678762.18389.1.camel@lb-tlvb-vladz>
 <1290851625.2794.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3328 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752273Ab0K1KXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 05:23:46 -0500
In-Reply-To: <1290851625.2794.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 94d5f59..e20b2d3 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1692,11 +1692,10 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 		}
 	}
 
-	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
-
-	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
+	if (skb_is_gso_v6(skb))
+		rc |= XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6;
+	else if (skb_is_gso(skb))
+		rc |= XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP;
 
 	return rc;
 }
-- 
1.7.0.4




