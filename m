From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 8/9] pch_gbe: run the ptp bpf just once per packet
Date: Sat, 21 Apr 2012 06:50:35 +0200
Message-ID: <2b417e6ea28228085740e31c150b90266313fe90.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57150 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab2DUEvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:51:10 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so6444663wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:51:09 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes code which needlessly ran the BPF twice per
packet. Instead, we just run the classifier once and test
whether the packet is any kind of PTP event message.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 53ac2fb..e9b785e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -134,10 +134,8 @@ static int pch_ptp_match(struct sk_buff *skb, u16 uid_hi, u32 uid_lo, u16 seqid)
 	u16 *hi, *id;
 	u32 lo;
 
-	if ((sk_run_filter(skb, ptp_filter) != PTP_CLASS_V2_IPV4) &&
-		(sk_run_filter(skb, ptp_filter) != PTP_CLASS_V1_IPV4)) {
+	if (sk_run_filter(skb, ptp_filter) == PTP_CLASS_NONE)
 		return 0;
-	}
 
 	offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
 
-- 
1.7.2.5
