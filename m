From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 9/9] net: tg3: avoid uninitialized variable warning
Date: Wed, 27 Jan 2016 15:04:59 +0100
Message-ID: <1453903507-3427225-10-git-send-email-arnd@arndb.de>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tg3_set_eeprom() function correctly initializes the 'start' variable,
but gcc generates a false warning:

drivers/net/ethernet/broadcom/tg3.c: In function 'tg3_set_eeprom':
drivers/net/ethernet/broadcom/tg3.c:12057:4: warning: 'start' may be used uninitialized in this function [-Wmaybe-uninitialized]

I have not come up with a way to restructure the code in a way that
avoids the warning without making it less readable, so this adds an
initialization for the declaration to shut up that warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9293675df7ba..49eea8981332 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12016,7 +12016,7 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	int ret;
 	u32 offset, len, b_offset, odd_len;
 	u8 *buf;
-	__be32 start, end;
+	__be32 start = 0, end;
 
 	if (tg3_flag(tp, NO_NVRAM) ||
 	    eeprom->magic != TG3_EEPROM_MAGIC)
-- 
2.7.0
