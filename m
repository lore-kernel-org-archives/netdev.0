From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/9] pch_gbe: scale time stamps to nanoseconds
Date: Sat, 21 Apr 2012 06:50:28 +0200
Message-ID: <417f8a10fc257bb83fe02019903f679afb16d541.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47181 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab2DUEuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:50:52 -0400
Received: by wejx9 with SMTP id x9so6444599wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:50:51 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

This patch fixes the helper functions that give the transmit and
receive time stamps to return nanoseconds, instead of arbitrary clock
ticks.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    4 ----
 drivers/ptp/ptp_pch.c                              |    2 ++
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 8035e5f..7c2dabb 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -101,8 +101,6 @@ const char pch_driver_version[] = DRV_VERSION;
 
 #ifdef CONFIG_PCH_PTP
 /* Macros for ieee1588 */
-#define TICKS_NS_SHIFT  5
-
 /* 0x40 Time Synchronization Channel Control Register Bits */
 #define MASTER_MODE   (1<<0)
 #define SLAVE_MODE    (0<<0)
@@ -183,7 +181,6 @@ static void pch_rx_timestamp(
 		goto out;
 
 	ns = pch_rx_snap_read(pdev);
-	ns <<= TICKS_NS_SHIFT;
 
 	shhwtstamps = skb_hwtstamps(skb);
 	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
@@ -226,7 +223,6 @@ static void pch_tx_timestamp(
 	}
 
 	ns = pch_tx_snap_read(pdev);
-	ns <<= TICKS_NS_SHIFT;
 
 	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 	shhwtstamps.hwtstamp = ns_to_ktime(ns);
diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 375eb04..847a3c3 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -261,6 +261,7 @@ u64 pch_rx_snap_read(struct pci_dev *pdev)
 
 	ns = ((u64) hi) << 32;
 	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
 
 	return ns;
 }
@@ -277,6 +278,7 @@ u64 pch_tx_snap_read(struct pci_dev *pdev)
 
 	ns = ((u64) hi) << 32;
 	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
 
 	return ns;
 }
-- 
1.7.2.5
