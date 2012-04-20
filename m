From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3.4-rc 2/9] pch_gbe: simplify transmit time stamping flag test
Date: Fri, 20 Apr 2012 22:09:21 +0200
Message-ID: <534472e5bb305753a66dc0b536d00114dd7bed03.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63894 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab2DTUKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:10:00 -0400
Received: by mail-we0-f174.google.com with SMTP id x9so6300952wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:09:59 -0700 (PDT)
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
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
