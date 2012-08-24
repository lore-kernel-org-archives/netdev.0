From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Fix reporting of IPv4 full filters through ethtool
Date: Fri, 24 Aug 2012 20:59:54 +0100
Message-ID: <1345838394.2694.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345838325.2694.41.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9626 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932254Ab2HXT75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:59:57 -0400
In-Reply-To: <1345838325.2694.41.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ETHTOOL_GRXCLSRULE returns filters for a TCP/IPv4 or UDP/IPv4 4-tuple
with source and destination swapped.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 8cba2df..5faedd8 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -863,8 +863,8 @@ static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 				       &ip_entry->ip4dst, &ip_entry->pdst);
 	if (rc != 0) {
 		rc = efx_filter_get_ipv4_full(
-			&spec, &proto, &ip_entry->ip4src, &ip_entry->psrc,
-			&ip_entry->ip4dst, &ip_entry->pdst);
+			&spec, &proto, &ip_entry->ip4dst, &ip_entry->pdst,
+			&ip_entry->ip4src, &ip_entry->psrc);
 		EFX_WARN_ON_PARANOID(rc);
 		ip_mask->ip4src = ~0;
 		ip_mask->psrc = ~0;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
