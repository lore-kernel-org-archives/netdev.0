From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/9] pch_gbe: simplify transmit time stamping flag test
Date: Sat, 21 Apr 2012 06:50:29 +0200
Message-ID: <1bdda1655991dca17f5f37f3c992ad060f84e95c.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:46447 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab2DUEuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:50:54 -0400
Received: by wibhj6 with SMTP id hj6so1246943wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:50:53 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

This patch makes logic surrounding the test of the
transmit time stamping flag more readable.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 7c2dabb..6a9a63b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -199,11 +199,11 @@ static void pch_tx_timestamp(
 	u32 cnt, val;
 
 	shtx = skb_shinfo(skb);
-	if (unlikely(shtx->tx_flags & SKBTX_HW_TSTAMP && adapter->hwts_tx_en))
-		shtx->tx_flags |= SKBTX_IN_PROGRESS;
-	else
+	if (likely(!(shtx->tx_flags & SKBTX_HW_TSTAMP && adapter->hwts_tx_en)))
 		return;
 
+	shtx->tx_flags |= SKBTX_IN_PROGRESS;
+
 	/* Get ieee1588's dev information */
 	pdev = adapter->ptp_pdev;
 
-- 
1.7.2.5
