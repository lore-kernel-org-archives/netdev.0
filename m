From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/8] sfc: QT2025C: Add error message for suspected bad SFP+
	cables
Date: Wed, 23 Dec 2009 23:48:42 +0000
Message-ID: <1261612122.2782.100.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28288 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757509AbZLWXso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:48:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some cables have EEPROMs that conflict with the PHY's on-board EEPROM
so it cannot load firmware.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/qt202x_phy.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 326ffa4..ff8f0a4 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -87,8 +87,14 @@ static int qt2025c_wait_heartbeat(struct efx_nic *efx)
 			old_counter = counter;
 		else if (counter != old_counter)
 			break;
-		if (time_after(jiffies, timeout))
+		if (time_after(jiffies, timeout)) {
+			/* Some cables have EEPROMs that conflict with the
+			 * PHY's on-board EEPROM so it cannot load firmware */
+			EFX_ERR(efx, "If an SFP+ direct attach cable is"
+				" connected, please check that it complies"
+				" with the SFP+ specification\n");
 			return -ETIMEDOUT;
+		}
 		msleep(QT2025C_HEARTB_WAIT);
 	}
 
-- 
1.5.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

