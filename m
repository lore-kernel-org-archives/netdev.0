From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] staging: r8188eu: Fix crash caused by commit 99aded71b52c
Date: Sun,  5 Jun 2016 10:21:30 -0500
Message-ID: <1465140090-20241-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Jacky Boen <aqiank@gmail.com>, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

Commit 99aded71b52cfdfa22721c42e42efdd13a02f0a6 ("Staging: drivers: rtl8188eu:
use sizeof(*ptr) instead of sizeof(struct)") introduces an error in that the
sizeof(struct hal_data_8188e) is 18712, while the sizeof(*adapt->HalData) is
only 1! As a result, the system panics.

Fixes: 99aded71b52cfdfa22721c42e42efdd13a02f0a6 ("Staging: drivers: rtl8188eu: use sizeof(*ptr) instead of sizeof(struct)")
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jacky Boen <aqiank@gmail.com>
---
V2 - Remove extra blank line inserted by mistake.
---
 drivers/staging/rtl8188eu/hal/usb_halinit.c | 2 +-
 1 file changed, 1 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/rtl8188eu/hal/usb_halinit.c b/drivers/staging/rtl8188eu/hal/usb_halinit.c
index 87ea3b8..363f3a3 100644
--- a/drivers/staging/rtl8188eu/hal/usb_halinit.c
+++ b/drivers/staging/rtl8188eu/hal/usb_halinit.c
@@ -2072,7 +2072,7 @@ void rtl8188eu_set_hal_ops(struct adapter *adapt)
 {
 	struct hal_ops	*halfunc = &adapt->HalFunc;
 
-	adapt->HalData = kzalloc(sizeof(*adapt->HalData), GFP_KERNEL);
+	adapt->HalData = kzalloc(sizeof(struct hal_data_8188e), GFP_KERNEL);
 	if (!adapt->HalData)
 		DBG_88E("cant not alloc memory for HAL DATA\n");
 
-- 
2.1.4
