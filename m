From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/8] e1000: FIX: fix wrong txdctl threshold bitmasks
Date: Tue, 17 Oct 2006 12:02:39 -0700
Message-ID: <20061017190239.4194.37827.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:16910 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751433AbWJQSxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:53:53 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Threshold bitmasks for prefetch, host and writeback were clearing
bits that they were not supposed to. The leftmost 2 bits in the byte
for each threshold are reserved.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 112447f..449a603 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1961,9 +1961,9 @@ struct e1000_hw {
 #define E1000_RXDCTL_GRAN    0x01000000 /* RXDCTL Granularity */
 
 /* Transmit Descriptor Control */
-#define E1000_TXDCTL_PTHRESH 0x000000FF /* TXDCTL Prefetch Threshold */
-#define E1000_TXDCTL_HTHRESH 0x0000FF00 /* TXDCTL Host Threshold */
-#define E1000_TXDCTL_WTHRESH 0x00FF0000 /* TXDCTL Writeback Threshold */
+#define E1000_TXDCTL_PTHRESH 0x0000003F /* TXDCTL Prefetch Threshold */
+#define E1000_TXDCTL_HTHRESH 0x00003F00 /* TXDCTL Host Threshold */
+#define E1000_TXDCTL_WTHRESH 0x003F0000 /* TXDCTL Writeback Threshold */
 #define E1000_TXDCTL_GRAN    0x01000000 /* TXDCTL Granularity */
 #define E1000_TXDCTL_LWTHRESH 0xFE000000 /* TXDCTL Low Threshold */
 #define E1000_TXDCTL_FULL_TX_DESC_WB 0x01010000 /* GRAN=1, WTHRESH=1 */



---
Auke Kok <auke-jan.h.kok@intel.com>
