From: Colin King <colin.king@canonical.com>
Subject: [PATCH 2/2] b43legacy: fix unitialized reads of ret by initializing the array to zero
Date: Tue,  5 Sep 2017 19:16:58 +0100
Message-ID: <20170905181658.23893-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The u8 char array ret is not being initialized and elements outside
the range start to end contain just garbage values from the stack.
This results in a later scan of the array to read potentially
uninitialized values.  Fix this by initializing the array to zero.
This seems to have been an issue since the very first commit.

Detected by CoverityScan CID#139653 ("Uninitialized scalar variable")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/broadcom/b43legacy/radio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/b43legacy/radio.c b/drivers/net/wireless/broadcom/b43legacy/radio.c
index 9501420340a9..eab1c9387846 100644
--- a/drivers/net/wireless/broadcom/b43legacy/radio.c
+++ b/drivers/net/wireless/broadcom/b43legacy/radio.c
@@ -280,7 +280,7 @@ u8 b43legacy_radio_aci_detect(struct b43legacy_wldev *dev, u8 channel)
 u8 b43legacy_radio_aci_scan(struct b43legacy_wldev *dev)
 {
 	struct b43legacy_phy *phy = &dev->phy;
-	u8 ret[13];
+	u8 ret[13] = { 0 };
 	unsigned int channel = phy->channel;
 	unsigned int i;
 	unsigned int j;
-- 
2.14.1
