From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/3] mdio: Expose pause frame advertising flags to ethtool
Date: Mon, 12 Oct 2009 20:26:37 +0100
Message-ID: <1255375597.2931.13.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43796 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757971AbZJLT1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 15:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mdio45_ethtool_gset_npage() and mdio45_ethtool_gset(), check MDIO
pause frame advertising flags and set the corresponding ethtool flags.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index c0db9d7..e85bf04 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -162,6 +162,10 @@ static u32 mdio45_get_an(const struct mdio_if_info *mdio, u16 addr)
 		result |= ADVERTISED_100baseT_Half;
 	if (reg & ADVERTISE_100FULL)
 		result |= ADVERTISED_100baseT_Full;
+	if (reg & ADVERTISE_PAUSE_CAP)
+		result |= ADVERTISED_Pause;
+	if (reg & ADVERTISE_PAUSE_ASYM)
+		result |= ADVERTISED_Asym_Pause;
 	return result;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

