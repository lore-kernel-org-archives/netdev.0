From: Marina Makienko <makienko@ispras.ru>
Subject: [PATCH] net: Checking usb_register() return value
Date: Tue, 14 Aug 2012 12:11:30 +0400
Message-ID: <1344931890-15763-1-git-send-email-makienko@ispras.ru>
Cc: Marina Makienko <makienko@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ath6kl_usb_init() does not check usb_register() return value.
As a result it may incorrectly report success of driver initialization.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Marina Makienko <makienko@ispras.ru>
---
 drivers/net/wireless/ath/ath6kl/usb.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/usb.c b/drivers/net/wireless/ath/ath6kl/usb.c
index 3740c3d..39f05da 100644
--- a/drivers/net/wireless/ath/ath6kl/usb.c
+++ b/drivers/net/wireless/ath/ath6kl/usb.c
@@ -1196,7 +1196,11 @@ static struct usb_driver ath6kl_usb_driver = {
 
 static int ath6kl_usb_init(void)
 {
-	usb_register(&ath6kl_usb_driver);
+	int ret = usb_register(&ath6kl_usb_driver);
+	if (ret) {
+		ath6kl_err("usb_register() failed: %d\n", ret);
+		return ret;
+	}
 	return 0;
 }
 
-- 
1.7.7
