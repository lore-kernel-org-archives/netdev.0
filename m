From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/16] sfc: Name the RX drop queue ID
Date: Tue, 27 Aug 2013 21:43:55 +0100
Message-ID: <1377636235.13272.78.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:65510 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab3H0Un7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:43:59 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c | 4 ++--
 drivers/net/ethernet/sfc/filter.h  | 7 ++++++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 4db37f7..ec5cacd 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -822,7 +822,7 @@ static int efx_ethtool_get_class_rule(struct efx_nic *efx,
 	if (rc)
 		return rc;
 
-	if (spec.dmaq_id == 0xfff)
+	if (spec.dmaq_id == EFX_FILTER_RX_DMAQ_ID_DROP)
 		rule->ring_cookie = RX_CLS_FLOW_DISC;
 	else
 		rule->ring_cookie = spec.dmaq_id;
@@ -967,7 +967,7 @@ static int efx_ethtool_set_class_rule(struct efx_nic *efx,
 	efx_filter_init_rx(&spec, EFX_FILTER_PRI_MANUAL,
 			   efx->rx_scatter ? EFX_FILTER_FLAG_RX_SCATTER : 0,
 			   (rule->ring_cookie == RX_CLS_FLOW_DISC) ?
-			   0xfff : rule->ring_cookie);
+			   EFX_FILTER_RX_DMAQ_ID_DROP : rule->ring_cookie);
 
 	switch (rule->flow_type) {
 	case TCP_V4_FLOW:
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index 5cb5472..b1170d4 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -76,7 +76,8 @@ enum efx_filter_flags {
  * @type: Type of match to be performed, from &enum efx_filter_type
  * @priority: Priority of the filter, from &enum efx_filter_priority
  * @flags: Miscellaneous flags, from &enum efx_filter_flags
- * @dmaq_id: Source/target queue index
+ * @dmaq_id: Source/target queue index, or %EFX_FILTER_RX_DMAQ_ID_DROP for
+ *	an RX drop filter
  * @data: Match data (type-dependent)
  *
  * Use the efx_filter_set_*() functions to initialise the @type and
@@ -94,6 +95,10 @@ struct efx_filter_spec {
 	u32	data[3];
 };
 
+enum {
+	EFX_FILTER_RX_DMAQ_ID_DROP = 0xfff
+};
+
 static inline void efx_filter_init_rx(struct efx_filter_spec *spec,
 				      enum efx_filter_priority priority,
 				      enum efx_filter_flags flags,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
