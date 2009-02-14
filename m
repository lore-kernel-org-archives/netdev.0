From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 26/43] drivers/net/sfc: fix sparse warning: symbol shadows an
	earlier one
Date: Sat, 14 Feb 2009 22:41:03 +0100
Message-ID: <20090214213932.24377.94262.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754501AbZBNVlU@vger.kernel.org>
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Move variable declaration as close to their usage as possible.

Fix this sparse warning:
  drivers/net/sfc/tenxpress.c:589:22: warning: symbol 'link_ok' shadows an earlier one
  drivers/net/sfc/tenxpress.c:575:30: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/sfc/tenxpress.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index ac9eeab..5b0f451 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -572,15 +572,14 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 static void tenxpress_phy_poll(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	bool change = false, link_ok;
-	unsigned link_fc;
+	bool change = false;
 
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
-		link_ok = sfx7101_link_ok(efx);
+		bool link_ok = sfx7101_link_ok(efx);
 		if (link_ok != efx->link_up) {
 			change = true;
 		} else {
-			link_fc = mdio_clause45_get_pause(efx);
+			unsigned int link_fc = mdio_clause45_get_pause(efx);
 			if (link_fc != efx->link_fc)
 				change = true;
 		}
