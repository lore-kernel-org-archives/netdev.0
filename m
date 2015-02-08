From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] at86rf230: assign wait_for_completion_timeout to appropriately typed var
Date: Sun,  8 Feb 2015 03:55:00 -0500
Message-ID: <1423385700-11125-1-git-send-email-hofrat@osadl.org>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

return type of wait_for_completion_timeout is unsigned long not int.
As rc is used here only for wait_for_completion_timeout the type is simply
changed to unsigned long.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_IEEE802154=m, 
CONFIG_MAC802154=m CONFIG_SPI=m, CONFIG_IEEE802154_AT86RF230=m

Patch is against 3.19.0-rc7 (localversion-next is -next-20150204)

 drivers/net/ieee802154/at86rf230.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 7b051ea..cbfc8c5 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -689,7 +689,7 @@ at86rf230_sync_state_change_complete(void *context)
 static int
 at86rf230_sync_state_change(struct at86rf230_local *lp, unsigned int state)
 {
-	int rc;
+	unsigned long rc;
 
 	at86rf230_async_state_change(lp, &lp->state, state,
 				     at86rf230_sync_state_change_complete,
-- 
1.7.10.4
