From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: mii: report 0 for unknown lp_advertising
Date: Tue,  8 Nov 2016 14:31:38 +0100
Message-ID: <20161108133232.1571441-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The newly introduced mii_ethtool_get_link_ksettings function sets
lp_advertising to an uninitialized value when BMCR_ANENABLE is not
set:

drivers/net/mii.c: In function 'mii_ethtool_get_link_ksettings':
drivers/net/mii.c:224:2: error: 'lp_advertising' may be used uninitialized in this function [-Werror=maybe-uninitialized]

As documented in include/uapi/linux/ethtool.h, the value is
expected to be zero when we don't know it, so let's initialize
it to that.

Fixes: bc8ee596afe8 ("net: mii: add generic function to support ksetting support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/mii.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 0443546fc427..6d953c53eed6 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -213,6 +213,8 @@ int mii_ethtool_get_link_ksettings(struct mii_if_info *mii,
 				    SPEED_100 : SPEED_10));
 		cmd->base.duplex = (bmcr & BMCR_FULLDPLX) ?
 			DUPLEX_FULL : DUPLEX_HALF;
+
+		lp_advertising = 0;
 	}
 
 	mii->full_duplex = cmd->base.duplex;
-- 
2.9.0
