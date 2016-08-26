From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, net-next] qede: hide 32-bit compile warning
Date: Fri, 26 Aug 2016 17:37:53 +0200
Message-ID: <20160826153808.838861-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
        Manish Chopra <manish.chopra@qlogic.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        Ariel Elior <Ariel.Elior@qlogic.com>,
        everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The addition of the per-queue statistics introduced a harmless warning
on all 32-bit architectures:

drivers/net/ethernet/qlogic/qede/qede_ethtool.c: In function 'qede_get_ethtool_stats':
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:244:31: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
      buf[cnt++] = QEDE_TQSTATS_DATA(edev,
                               ^
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:244:22: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
      buf[cnt++] = QEDE_TQSTATS_DATA(edev,
                      ^
This changes the cast to 'void *' to shut up the warning, which
avoids the assumptions on the size of the pointer type.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 68db9ec2df07 ("qede: Add support for per-queue stats.")
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 4d45945bc34c..14d5328e6ac9 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -60,7 +60,7 @@ static const struct {
 };
 
 #define QEDE_TQSTATS_DATA(dev, sindex, tssid, tcid) \
-	(*((u64 *)(((u64)(&dev->fp_array[tssid].txqs[tcid])) +\
+	(*((u64 *)(((void *)(&dev->fp_array[tssid].txqs[tcid])) +\
 		   qede_tqstats_arr[(sindex)].offset)))
 
 static const struct {
-- 
2.9.0
