From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: bcmgenet: fix off-by-one comparison on timeout
Date: Tue, 28 Feb 2017 12:18:51 +0000
Message-ID: <20170228121851.21145-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

At the end of the timeout loop, timeout will be 1001 and not 1000 and
so the timeout error will never be detected. Fix the off-by-one
comparison by checking to see if timeout is greater than 1000.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f928968..24e7201 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1829,7 +1829,7 @@ static int reset_umac(struct bcmgenet_priv *priv)
 		udelay(1);
 	}
 
-	if (timeout == 1000) {
+	if (timeout > 1000) {
 		dev_err(kdev,
 			"timeout waiting for MAC to come out of reset\n");
 		return -ETIMEDOUT;
-- 
2.10.2
