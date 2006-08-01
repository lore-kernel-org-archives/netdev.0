From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH 6/6] zd1211rw: Packet filter fix for managed (STA) mode
Date: Tue, 01 Aug 2006 23:43:35 +0200
Message-ID: <11544686162894-git-send-email-kune@deine-taler.de>
References: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:29380 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751137AbWHAVnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:37 -0400
To: linville@tuxdriver.com
In-Reply-To: <1154468615618-git-send-email-kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had problems with my AVM Fritz!Box access point. It appeared
that the AP deauthorized me and the softmac didn't reconnect me.
This patch handles the problem.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 drivers/net/wireless/zd1211rw/zd_chip.c |    4 ++--
 drivers/net/wireless/zd1211rw/zd_chip.h |    6 +++---
 drivers/net/wireless/zd1211rw/zd_mac.c  |    5 +----
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index efc9c4b..da9d06b 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -797,7 +797,7 @@ static int zd1211_hw_init_hmac(struct zd
 		{ CR_ADDA_MBIAS_WARMTIME,	0x30000808 },
 		{ CR_ZD1211_RETRY_MAX,		0x2 },
 		{ CR_SNIFFER_ON,		0 },
-		{ CR_RX_FILTER,			AP_RX_FILTER },
+		{ CR_RX_FILTER,			STA_RX_FILTER },
 		{ CR_GROUP_HASH_P1,		0x00 },
 		{ CR_GROUP_HASH_P2,		0x80000000 },
 		{ CR_REG1,			0xa4 },
@@ -844,7 +844,7 @@ static int zd1211b_hw_init_hmac(struct z
 		{ CR_ZD1211B_AIFS_CTL2,		0x008C003C },
 		{ CR_ZD1211B_TXOP,		0x01800824 },
 		{ CR_SNIFFER_ON,		0 },
-		{ CR_RX_FILTER,			AP_RX_FILTER },
+		{ CR_RX_FILTER,			STA_RX_FILTER },
 		{ CR_GROUP_HASH_P1,		0x00 },
 		{ CR_GROUP_HASH_P2,		0x80000000 },
 		{ CR_REG1,			0xa4 },
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 0eb9c8f..069d2b4 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -466,6 +466,9 @@ #define RX_FILTER_PROBE_RESPONSE	0x0020
 #define RX_FILTER_BEACON		0x0100
 #define RX_FILTER_DISASSOC		0x0400
 #define RX_FILTER_AUTH			0x0800
+#define AP_RX_FILTER			0x0400feff
+#define STA_RX_FILTER			0x0000ffff
+
 /* Monitor mode sets filter to 0xfffff */
 
 #define CR_ACK_TIMEOUT_EXT		CTL_REG(0x0690)
@@ -548,9 +551,6 @@ #define CR_ZD1211B_AIFS_CTL2		CTL_REG(0x
 #define CR_ZD1211B_TXOP			CTL_REG(0x0b20)
 #define CR_ZD1211B_RETRY_MAX		CTL_REG(0x0b28)
 
-#define AP_RX_FILTER			0x0400feff
-#define STA_RX_FILTER			0x0000ffff
-
 #define CWIN_SIZE			0x007f043f
 
 
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a66625c..d6f3e02 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -138,10 +138,7 @@ static int reset_mode(struct zd_mac *mac
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 	struct zd_ioreq32 ioreqs[3] = {
-		{ CR_RX_FILTER, RX_FILTER_BEACON | RX_FILTER_PROBE_RESPONSE |
-			        RX_FILTER_AUTH | RX_FILTER_ASSOC_RESPONSE |
-				RX_FILTER_REASSOC_RESPONSE |
-				RX_FILTER_DISASSOC },
+		{ CR_RX_FILTER, STA_RX_FILTER },
 		{ CR_SNIFFER_ON, 0U },
 	};
 
-- 
1.4.1

