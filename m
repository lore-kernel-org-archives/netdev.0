From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 02/17] sfc: Fix condition for no-op in
 set_phy_flash_cfg()
Date: Thu, 02 Dec 2010 23:46:14 +0000
Message-ID: <1291333574.3259.25.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12954 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186Ab0LBXqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:46:17 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_boards.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index cfc6a5b..cfc29d7 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -325,7 +325,7 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 		new_mode = old_mode & ~PHY_MODE_SPECIAL;
 	else
 		new_mode = PHY_MODE_SPECIAL;
-	if (old_mode == new_mode) {
+	if (!((old_mode ^ new_mode) & PHY_MODE_SPECIAL)) {
 		err = 0;
 	} else if (efx->state != STATE_RUNNING || netif_running(efx->net_dev)) {
 		err = -EBUSY;
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

