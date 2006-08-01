From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH 2/6] zd1211rw: Pass more management frame types up to host
Date: Tue, 01 Aug 2006 23:43:31 +0200
Message-ID: <1154468615613-git-send-email-kune@deine-taler.de>
References: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:26820 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751066AbWHAVng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:36 -0400
To: linville@tuxdriver.com
In-Reply-To: <1154468615618-git-send-email-kune@deine-taler.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Drake <dsd@gentoo.org>

We'll be needing these at some point...

Signed-off-by: Daniel Drake <dsd@gentoo.org>
Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 drivers/net/wireless/zd1211rw/zd_chip.h |    4 +++-
 drivers/net/wireless/zd1211rw/zd_mac.c  |    6 ++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 8051210..0eb9c8f 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -461,10 +461,12 @@ #define CR_UNDERRUN_CNT			CTL_REG(0x0688
 
 #define CR_RX_FILTER			CTL_REG(0x068c)
 #define RX_FILTER_ASSOC_RESPONSE	0x0002
+#define RX_FILTER_REASSOC_RESPONSE	0x0008
 #define RX_FILTER_PROBE_RESPONSE	0x0020
 #define RX_FILTER_BEACON		0x0100
+#define RX_FILTER_DISASSOC		0x0400
 #define RX_FILTER_AUTH			0x0800
-/* Sniff modus sets filter to 0xfffff */
+/* Monitor mode sets filter to 0xfffff */
 
 #define CR_ACK_TIMEOUT_EXT		CTL_REG(0x0690)
 #define CR_BCN_FIFO_SEMAPHORE		CTL_REG(0x0694)
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index b394303..1cf1fda 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -136,8 +136,10 @@ static int reset_mode(struct zd_mac *mac
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 	struct zd_ioreq32 ioreqs[3] = {
-		{ CR_RX_FILTER, RX_FILTER_BEACON|RX_FILTER_PROBE_RESPONSE|
-			        RX_FILTER_AUTH|RX_FILTER_ASSOC_RESPONSE },
+		{ CR_RX_FILTER, RX_FILTER_BEACON | RX_FILTER_PROBE_RESPONSE |
+			        RX_FILTER_AUTH | RX_FILTER_ASSOC_RESPONSE |
+				RX_FILTER_REASSOC_RESPONSE |
+				RX_FILTER_DISASSOC },
 		{ CR_SNIFFER_ON, 0U },
 		{ CR_ENCRYPTION_TYPE, NO_WEP },
 	};
-- 
1.4.1

