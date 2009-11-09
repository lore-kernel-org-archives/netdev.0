From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 1/4] bnx2x: GSO implies CSUM offload
Date: Mon, 9 Nov 2009 18:09:22 +0200
Message-ID: <1257782962.4101.40.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2789 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbZKIQNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 11:13:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Making sure that whenever the FW/HW is configured for GSO, it is also configured
to CSUM offload

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 61974b7..856ca38 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11121,10 +11121,10 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 	}
 
 	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-		rc |= XMIT_GSO_V4;
+		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
 
 	else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-		rc |= XMIT_GSO_V6;
+		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
 
 	return rc;
 }
-- 
1.5.4.3




