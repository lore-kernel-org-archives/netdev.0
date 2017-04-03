From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH -next] liquidio: clear the correct memory
Date: Mon, 3 Apr 2017 21:18:27 +0300
Message-ID: <20170403181827.GA6505@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Prasad Kanneganti <prasad.kanneganti@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45979 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752783AbdDCSTs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 14:19:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a cut and paste bug here so we accidentally clear the first
few bytes of "resp" a second time instead clearing "ctx".

Fixes: 50c0add534d2 ("liquidio: refactor interrupt moderation code")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index fac02ed2c449..dab10c7e4443 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -1359,7 +1359,7 @@ static int octnet_get_intrmod_cfg(struct lio *lio,
 	memset(resp, 0, sizeof(struct oct_intrmod_resp));
 
 	ctx = (struct oct_intrmod_context *)sc->ctxptr;
-	memset(resp, 0, sizeof(struct oct_intrmod_context));
+	memset(ctx, 0, sizeof(struct oct_intrmod_context));
 	WRITE_ONCE(ctx->cond, 0);
 	ctx->octeon_id = lio_get_device_id(oct_dev);
 	init_waitqueue_head(&ctx->wc);
