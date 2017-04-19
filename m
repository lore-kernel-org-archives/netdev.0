From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] liquidio: remove unnecessary variable assignment
Date: Wed, 19 Apr 2017 19:30:59 +0200
Message-ID: <20170419173109.3683437-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Prasad Kanneganti <prasad.kanneganti@cavium.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:49500 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967462AbdDSRbV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 13:31:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc points out an useless assignment that was added during code refactoring:

drivers/net/ethernet/cavium/liquidio/lio_ethtool.c: In function 'octnet_intrmod_callback':
drivers/net/ethernet/cavium/liquidio/lio_ethtool.c:1315:59: error: parameter 'oct_dev' set but not used [-Werror=unused-but-set-parameter]

This is harmless but can clearly be remove to avoid the warning.

Fixes: 50c0add534d2 ("liquidio: refactor interrupt moderation code")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index dab10c7e4443..579dc7336f58 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -1323,8 +1323,6 @@ static void octnet_intrmod_callback(struct octeon_device *oct_dev,
 
 	ctx->status = status;
 
-	oct_dev = lio_get_device(ctx->octeon_id);
-
 	WRITE_ONCE(ctx->cond, 1);
 
 	/* This barrier is required to be sure that the response has been
-- 
2.9.0
