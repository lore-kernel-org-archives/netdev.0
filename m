From: Colin King <colin.king@canonical.com>
Subject: [PATCH] b43: make const arrays static, reduces object code size
Date: Fri, 22 Sep 2017 16:39:02 +0100
Message-ID: <20170922153902.15372-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        b43-dev@lists.infradead.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Don't populate const arrays on the stack, instead make them static.
Makes the object code smaller by over 60 bytes:

Before:
   text	   data	    bss	    dec	    hex	filename
  14816	   1296	      0	  16112	   3ef0	b43/phy_ht.o

After:
   text	   data	    bss	    dec	    hex	filename
  14551	   1496	      0	  16047	   3eaf	b43/phy_ht.o

(gcc 6.3.0, x86-64)

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/broadcom/b43/phy_ht.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43/phy_ht.c b/drivers/net/wireless/broadcom/b43/phy_ht.c
index 718c90e81696..c3158d085c2b 100644
--- a/drivers/net/wireless/broadcom/b43/phy_ht.c
+++ b/drivers/net/wireless/broadcom/b43/phy_ht.c
@@ -119,7 +119,7 @@ static void b43_radio_2059_rcal(struct b43_wldev *dev)
 /* Calibrate the internal RC oscillator? */
 static void b43_radio_2057_rccal(struct b43_wldev *dev)
 {
-	const u16 radio_values[3][2] = {
+	static const u16 radio_values[3][2] = {
 		{ 0x61, 0xE9 }, { 0x69, 0xD5 }, { 0x73, 0x99 },
 	};
 	int i;
@@ -154,7 +154,7 @@ static void b43_radio_2059_init_pre(struct b43_wldev *dev)
 
 static void b43_radio_2059_init(struct b43_wldev *dev)
 {
-	const u16 routing[] = { R2059_C1, R2059_C2, R2059_C3 };
+	static const u16 routing[] = { R2059_C1, R2059_C2, R2059_C3 };
 	int i;
 
 	/* Prepare (reset?) radio */
@@ -263,7 +263,7 @@ static void b43_phy_ht_reset_cca(struct b43_wldev *dev)
 static void b43_phy_ht_zero_extg(struct b43_wldev *dev)
 {
 	u8 i, j;
-	u16 base[] = { 0x40, 0x60, 0x80 };
+	static const u16 base[] = { 0x40, 0x60, 0x80 };
 
 	for (i = 0; i < ARRAY_SIZE(base); i++) {
 		for (j = 0; j < 4; j++)
-- 
2.14.1
