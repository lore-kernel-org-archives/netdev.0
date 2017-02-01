From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] sfc: a couple off by one bugs
Date: Wed, 1 Feb 2017 11:50:40 +0300
Message-ID: <20170201085040.GA31514@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31263 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbdBAIvP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 03:51:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These checks are off by one.  These are just sanity checks and we don't
ever pass invalid values for "encap_type" so it's harmless.

Fixes: 9b4108012517 ("sfc: insert catch-all filters for encapsulated traffic")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 8bec9383d754..dec0c8083ff3 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5080,7 +5080,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 
 		/* quick bounds check (BCAST result impossible) */
 		BUILD_BUG_ON(EFX_EF10_BCAST != 0);
-		if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
+		if (encap_type >= ARRAY_SIZE(map) || map[encap_type] == 0) {
 			WARN_ON(1);
 			return -EINVAL;
 		}
@@ -5134,7 +5134,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 
 		/* quick bounds check (BCAST result impossible) */
 		BUILD_BUG_ON(EFX_EF10_BCAST != 0);
-		if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
+		if (encap_type >= ARRAY_SIZE(map) || map[encap_type] == 0) {
 			WARN_ON(1);
 			return -EINVAL;
 		}
