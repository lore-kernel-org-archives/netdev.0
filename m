From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/6] sfc: Fix internal indices of ethtool stats for EF10
Date: Tue, 8 Oct 2013 18:43:41 +0100
Message-ID: <1381254221.1530.12.camel@bwh-desktop.uk.level5networks.com>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56432 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833Ab3JHRnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:43:45 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

The indices in nic_data->stats need to match the EF10_STAT_whatever
enum values.  In efx_nic_update_stats, only mask; gaps are removed in
efx_ef10_update_stats.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/nic.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index e7dbd2d..9826594 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -469,8 +469,7 @@ size_t efx_nic_describe_stats(const struct efx_hw_stat_desc *desc, size_t count,
  * @count: Length of the @desc array
  * @mask: Bitmask of which elements of @desc are enabled
  * @stats: Buffer to update with the converted statistics.  The length
- *	of this array must be at least the number of set bits in the
- *	first @count bits of @mask.
+ *	of this array must be at least @count.
  * @dma_buf: DMA buffer containing hardware statistics
  * @accumulate: If set, the converted values will be added rather than
  *	directly stored to the corresponding elements of @stats
@@ -503,11 +502,9 @@ void efx_nic_update_stats(const struct efx_hw_stat_desc *desc, size_t count,
 			}
 
 			if (accumulate)
-				*stats += val;
+				stats[index] += val;
 			else
-				*stats = val;
+				stats[index] = val;
 		}
-
-		++stats;
 	}
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
