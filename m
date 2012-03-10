From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/10] sfc: Fix calculation of vf_i in
 map_vi_index()
Date: Sat, 10 Mar 2012 00:48:50 +0000
Message-ID: <1331340530.2537.11.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:32180 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756821Ab2CJAsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:48:53 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Stonehouse <rstonehouse@solarflare.com>

This was broken during refactoring to use efx_vf_size().

[bwh: Keep using efx_vf_size()]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/siena_sriov.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index 80976e8..9cb3b84 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -514,7 +514,7 @@ static bool map_vi_index(struct efx_nic *efx, unsigned abs_index,
 
 	if (abs_index < EFX_VI_BASE)
 		return true;
-	vf_i = (abs_index - EFX_VI_BASE) * efx_vf_size(efx);
+	vf_i = (abs_index - EFX_VI_BASE) / efx_vf_size(efx);
 	if (vf_i >= efx->vf_init_count)
 		return true;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
