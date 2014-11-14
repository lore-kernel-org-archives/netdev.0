From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Subject: [PATCH] carl9170: Convert byte_rev_table uses to bitrev8
Date: Fri, 14 Nov 2014 13:16:44 +0800
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D1829D@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "'chunkeey@googlemail.com'" <chunkeey@googlemail.com>,
	"'linville@tuxdriver.com'" <linville@tuxdriver.com>,
	"'linux-wireless@vger.kernel.org'" <linux-wireless@vger.kernel.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	"'joe@perches.com'" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the inline function instead of directly indexing the array.

This allows some architectures with hardware instructions for bit
reversals to eliminate the array.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 drivers/net/wireless/ath/carl9170/phy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/phy.c b/drivers/net/wireless/ath/carl9170/phy.c
index b80b213..dca6df1 100644
--- a/drivers/net/wireless/ath/carl9170/phy.c
+++ b/drivers/net/wireless/ath/carl9170/phy.c
@@ -994,7 +994,7 @@ static int carl9170_init_rf_bank4_pwr(struct ar9170 *ar, bool band5ghz,
 			refsel0 = 0;
 			refsel1 = 1;
 		}
-		chansel = byte_rev_table[chansel];
+		chansel = bitrev8(chansel);
 	} else {
 		if (freq == 2484) {
 			chansel = 10 + (freq - 2274) / 5;
@@ -1002,7 +1002,7 @@ static int carl9170_init_rf_bank4_pwr(struct ar9170 *ar, bool band5ghz,
 		} else
 			chansel = 16 + (freq - 2272) / 5;
 		chansel *= 4;
-		chansel = byte_rev_table[chansel];
+		chansel = bitrev8(chansel);
 	}
 
 	d1 =	chansel;
-- 
2.1.1
