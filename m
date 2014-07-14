From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/2] phy: Expand phy speed/duplex settings array
Date: Mon, 14 Jul 2014 14:05:46 -0500
Message-ID: <20140714190546.23626.22878.stgit@tlendack-t1.amdoffice.net>
References: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:12441
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752433AbaGNTF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2014 15:05:58 -0400
In-Reply-To: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expand the phy speed/duplex settings array to support more
than just baseT features. This change adds entries to support
the following additional speed/duplex/media types:
	SUPPORTED_10000baseKR_Full
	SUPPORTED_10000baseKX4_Full
	SUPPORTED_2500baseX_Full
	SUPPORTED_1000baseKX_Full

Additionally, it changes the 10GbE baseT entry from using the
hardcoded value 10000 to the SPEED_10000 define.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/phy.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f7c6181..e56e269 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -138,11 +138,31 @@ struct phy_setting {
 /* A mapping of all SUPPORTED settings to speed/duplex */
 static const struct phy_setting settings[] = {
 	{
-		.speed = 10000,
+		.speed = SPEED_10000,
+		.duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10000baseKR_Full,
+	},
+	{
+		.speed = SPEED_10000,
+		.duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_10000baseKX4_Full,
+	},
+	{
+		.speed = SPEED_10000,
 		.duplex = DUPLEX_FULL,
 		.setting = SUPPORTED_10000baseT_Full,
 	},
 	{
+		.speed = SPEED_2500,
+		.duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_2500baseX_Full,
+	},
+	{
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_FULL,
+		.setting = SUPPORTED_1000baseKX_Full,
+	},
+	{
 		.speed = SPEED_1000,
 		.duplex = DUPLEX_FULL,
 		.setting = SUPPORTED_1000baseT_Full,
