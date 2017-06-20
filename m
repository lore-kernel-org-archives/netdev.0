From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: phy: smsc: fix buffer overflow in memcpy
Date: Tue, 20 Jun 2017 22:40:46 +0200
Message-ID: <20170620204059.790066-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The memcpy annotation triggers for a fixed-length buffer copy:

In file included from /git/arm-soc/arch/arm64/include/asm/processor.h:30:0,
                 from /git/arm-soc/arch/arm64/include/asm/spinlock.h:21,
                 from /git/arm-soc/include/linux/spinlock.h:87,
                 from /git/arm-soc/include/linux/seqlock.h:35,
                 from /git/arm-soc/include/linux/time.h:5,
                 from /git/arm-soc/include/linux/stat.h:21,
                 from /git/arm-soc/include/linux/module.h:10,
                 from /git/arm-soc/drivers/net/phy/smsc.c:20:
In function 'memcpy',
    inlined from 'smsc_get_strings' at /git/arm-soc/drivers/net/phy/smsc.c:166:3:
/git/arm-soc/include/linux/string.h:309:4: error: call to '__read_overflow2' declared with attribute error: detected read beyond size of object passed as 2nd parameter

Using strncpy instead of memcpy should do the right thing here.

Fixes: 030a89028db0 ("net: phy: smsc: Implement PHY statistics")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/phy/smsc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 1b8204be064c..2306bfae057f 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -163,7 +163,7 @@ static void smsc_get_strings(struct phy_device *phydev, u8 *data)
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(smsc_hw_stats); i++) {
-		memcpy(data + i * ETH_GSTRING_LEN,
+		strncpy(data + i * ETH_GSTRING_LEN,
 		       smsc_hw_stats[i].string, ETH_GSTRING_LEN);
 	}
 }
-- 
2.9.0
