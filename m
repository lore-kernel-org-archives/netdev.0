From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 11/22] net: thunder_bgx: avoid format string overflow warning
Date: Fri, 14 Jul 2017 14:07:03 +0200
Message-ID: <20170714120720.906842-12-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: George Cherian <george.cherian@cavium.com>,
 "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
 linux-scsi@vger.kernel.org, "Martin K . Petersen" <martin.petersen@oracle.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org,
 Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
 Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>,
 Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org, Thanneeru Srinivasulu <tsrinivasulu@cavium.com>,
 akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>,
 "David S . Miller" <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
 Robert Richter <rric@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

gcc warns that the temporary buffer might be too small here:

drivers/net/ethernet/cavium/thunder/thunder_bgx.c: In function 'bgx_probe':
drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:16: error: '%d' directive writing between 1 and 10 bytes into a region of size between 9 and 11 [-Werror=format-overflow=]
sprintf(str, "BGX%d LMAC%d mode", bgx->bgx_id, lmacid);
             ^~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:16: note: directive argument in the range [0, 2147483647]
drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:3: note: 'sprintf' output between 16 and 27 bytes into a destination of size 20

This probably can't happen, but it can't hurt to make it long
enough for the theoretical limit.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index a0ca68ce3fbb..79112563a25a 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -1008,7 +1008,7 @@ static void bgx_print_qlm_mode(struct bgx *bgx, u8 lmacid)
 {
 	struct device *dev = &bgx->pdev->dev;
 	struct lmac *lmac;
-	char str[20];
+	char str[27];
 
 	if (!bgx->is_dlm && lmacid)
 		return;
-- 
2.9.0
