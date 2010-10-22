From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] net: NETIF_F_HW_CSUM does not imply FCoE CRC
 offload
Date: Fri, 22 Oct 2010 15:38:26 +0100
Message-ID: <1287758306.2316.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yi Zou <yi.zou@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53423 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757348Ab0JVOi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 10:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_HW_CSUM indicates the ability to update an TCP/IP-style 16-bit
checksum with the checksum of an arbitrary part of the packet data,
whereas the FCoE CRC is something entirely different.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org [2.6.32+]
---
 net/core/dev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a698252..8ab61de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1683,10 +1683,10 @@ EXPORT_SYMBOL(netif_device_attach);
 
 static bool can_checksum_protocol(unsigned long features, __be16 protocol)
 {
-	return ((features & NETIF_F_GEN_CSUM) ||
-		((features & NETIF_F_IP_CSUM) &&
+	return ((features & NETIF_F_NO_CSUM) ||
+		((features & NETIF_F_V4_CSUM) &&
 		 protocol == htons(ETH_P_IP)) ||
-		((features & NETIF_F_IPV6_CSUM) &&
+		((features & NETIF_F_V6_CSUM) &&
 		 protocol == htons(ETH_P_IPV6)) ||
 		((features & NETIF_F_FCOE_CRC) &&
 		 protocol == htons(ETH_P_FCOE)));
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

