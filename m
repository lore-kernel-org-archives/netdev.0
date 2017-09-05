From: Colin King <colin.king@canonical.com>
Subject: [PATCH 1/2] b43: fix unitialized reads of ret by initializing the array to zero
Date: Tue,  5 Sep 2017 19:15:50 +0100
Message-ID: <20170905181550.23839-1-colin.king@canonical.com>
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

The u8 char array ret is not being initialized and elements outside
the range start to end contain just garbage values from the stack.
This results in a later scan of the array to read potentially
uninitialized values.  Fix this by initializing the array to zero.
This seems to have been an issue since the very first commit.

Detected by CoverityScan CID#139652 ("Uninitialized scalar variable")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/broadcom/b43/phy_g.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/b43/phy_g.c b/drivers/net/wireless/broadcom/b43/phy_g.c
index 822dcaa8ace6..f59c02166462 100644
--- a/drivers/net/wireless/broadcom/b43/phy_g.c
+++ b/drivers/net/wireless/broadcom/b43/phy_g.c
@@ -2297,7 +2297,7 @@ static u8 b43_gphy_aci_detect(struct b43_wldev *dev, u8 channel)
 static u8 b43_gphy_aci_scan(struct b43_wldev *dev)
 {
 	struct b43_phy *phy = &dev->phy;
-	u8 ret[13];
+	u8 ret[13] = { 0 };
 	unsigned int channel = phy->channel;
 	unsigned int i, j, start, end;
 
-- 
2.14.1
