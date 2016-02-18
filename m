From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] b43: fix memory leak
Date: Thu, 18 Feb 2016 18:04:36 +0530
Message-ID: <1455798876-32186-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudip@vectorindia.org>

On error we jumped to the label bcma_out and returned the error code but
we missed freeing dev.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/wireless/broadcom/b43/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/broadcom/b43/main.c b/drivers/net/wireless/broadcom/b43/main.c
index c279211..78f670a 100644
--- a/drivers/net/wireless/broadcom/b43/main.c
+++ b/drivers/net/wireless/broadcom/b43/main.c
@@ -5671,6 +5671,7 @@ static int b43_bcma_probe(struct bcma_device *core)
 	wl = b43_wireless_init(dev);
 	if (IS_ERR(wl)) {
 		err = PTR_ERR(wl);
+		kfree(dev);
 		goto bcma_out;
 	}
 
-- 
1.9.1
