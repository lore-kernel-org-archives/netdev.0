From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] ieee802154: ca8210: Fix a potential NULL pointer dereference
Date: Sun, 20 Aug 2017 18:25:02 +0200
Message-ID: <20170820162502.4342-1-christophe.jaillet@wanadoo.fr>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: h.morris@cascoda.com, linuxdev@cascoda.com, alex.aring@gmail.com,
        stefan@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'spi' is known to be NULL, so we dereference a NULL pointer here.
Use 'pr_crit()' instead of 'dev_crit()' to report the message.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/ieee802154/ca8210.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ieee802154/ca8210.c b/drivers/net/ieee802154/ca8210.c
index 326243fae7e2..24a1eabbbc9d 100644
--- a/drivers/net/ieee802154/ca8210.c
+++ b/drivers/net/ieee802154/ca8210.c
@@ -917,10 +917,7 @@ static int ca8210_spi_transfer(
 	struct cas_control *cas_ctl;
 
 	if (!spi) {
-		dev_crit(
-			&spi->dev,
-			"NULL spi device passed to ca8210_spi_transfer\n"
-		);
+		pr_crit("NULL spi device passed to %s\n", __func__);
 		return -ENODEV;
 	}
 
-- 
2.11.0
