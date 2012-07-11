From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/11] sfc: Use strlcpy() to copy ethtool stats
 names
Date: Thu, 12 Jul 2012 00:16:58 +0100
Message-ID: <1342048618.2613.65.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19006 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751010Ab2GKXRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 19:17:01 -0400
In-Reply-To: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix CID 113703 in the Coverity report on Linux.

ethtool stats names are limited to 32 bytes including a null
terminator.  Use strlcpy() to ensure that we will always include the
null terminator even if a source string becomes longer than this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 03ded36..10536f9 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -453,7 +453,7 @@ static void efx_ethtool_get_strings(struct net_device *net_dev,
 	switch (string_set) {
 	case ETH_SS_STATS:
 		for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++)
-			strncpy(ethtool_strings[i].name,
+			strlcpy(ethtool_strings[i].name,
 				efx_ethtool_stats[i].name,
 				sizeof(ethtool_strings[i].name));
 		break;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
