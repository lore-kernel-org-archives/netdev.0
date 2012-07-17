From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/10] sfc: Work around bogus 'uninitialised
 variable' warning
Date: Tue, 17 Jul 2012 19:05:42 +0100
Message-ID: <1342548342.2698.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49376 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752853Ab2GQSFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:05:45 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With some gcc versions & optimisations, the compiler will warn that
'depth' in efx_filter_insert_filter() may be used without being
initialised, although this is not the case.

This is related to inlining of efx_filter_search(), which only has
one caller since commit 8db182f4a8a6e2dcb8b65905ea4af56210e65430
('sfc: Remove now-unused filter function').

Shut the compiler up by initialising it to 0.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index fea7f73..c3fd61f 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -662,7 +662,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
 	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
-	unsigned int filter_idx, depth;
+	unsigned int filter_idx, depth = 0;
 	u32 key;
 	int rc;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
