From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/7] staging: rtl8712: Fix some Sparse endian messages
Date: Fri, 10 Feb 2017 21:30:24 -0600
Message-ID: <20170211033030.28827-2-Larry.Finger@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Sparse reports the following:

  CHECK   drivers/staging/rtl8712/rtl8712_xmit.c
drivers/staging/rtl8712/rtl8712_xmit.c:564:42: warning: cast from restricted __le32
drivers/staging/rtl8712/rtl8712_xmit.c:569:42: warning: cast from restricted __le32
drivers/staging/rtl8712/rtl8712_xmit.c:571:42: warning: cast from restricted __le32

Each of these cases is transferring a quantity that is little-endian. There
is no need for conversion.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/rtl8712_xmit.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl8712_xmit.c b/drivers/staging/rtl8712/rtl8712_xmit.c
index 4231a0a..7fe6265 100644
--- a/drivers/staging/rtl8712/rtl8712_xmit.c
+++ b/drivers/staging/rtl8712/rtl8712_xmit.c
@@ -561,14 +561,14 @@ static void update_txdesc(struct xmit_frame *pxmitframe, uint *pmem, int sz)
 
 			ptxdesc_mp = &txdesc_mp;
 			/* offset 8 */
-			ptxdesc->txdw2 = cpu_to_le32(ptxdesc_mp->txdw2);
+			ptxdesc->txdw2 = ptxdesc_mp->txdw2;
 			if (bmcst)
 				ptxdesc->txdw2 |= cpu_to_le32(BMC);
 			ptxdesc->txdw2 |= cpu_to_le32(BK);
 			/* offset 16 */
-			ptxdesc->txdw4 = cpu_to_le32(ptxdesc_mp->txdw4);
+			ptxdesc->txdw4 = ptxdesc_mp->txdw4;
 			/* offset 20 */
-			ptxdesc->txdw5 = cpu_to_le32(ptxdesc_mp->txdw5);
+			ptxdesc->txdw5 = ptxdesc_mp->txdw5;
 			pattrib->pctrl = 0;/* reset to zero; */
 		}
 	} else if (pxmitframe->frame_tag == MGNT_FRAMETAG) {
-- 
2.10.2
