From: Fugang Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 2/6] net: fec: avoid BD pointer type cast to 32bit
Date: Tue, 11 Apr 2017 19:13:04 +0800
Message-ID: <1491909188-8971-3-git-send-email-fugang.duan@nxp.com>
References: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0059.outbound.protection.outlook.com ([104.47.34.59]:8556
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754624AbdDKLPV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:21 -0400
In-Reply-To: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In aarch64 system, the BD pointer is 64bit, and the high-order 32-bits
of the address is effective, so replace usigned with (void *) type to
aovid 64bit address is casted to 32bit in .fec_enet_get_nextdesc() and
.fec_enet_get_prevdesc() functions.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 886a9c9..172624c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -235,14 +235,14 @@ static struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp,
 					     struct bufdesc_prop *bd)
 {
 	return (bdp >= bd->last) ? bd->base
-			: (struct bufdesc *)(((unsigned)bdp) + bd->dsize);
+			: (struct bufdesc *)(((void *)bdp) + bd->dsize);
 }
 
 static struct bufdesc *fec_enet_get_prevdesc(struct bufdesc *bdp,
 					     struct bufdesc_prop *bd)
 {
 	return (bdp <= bd->base) ? bd->last
-			: (struct bufdesc *)(((unsigned)bdp) - bd->dsize);
+			: (struct bufdesc *)(((void *)bdp) - bd->dsize);
 }
 
 static int fec_enet_get_bd_index(struct bufdesc *bdp,
-- 
1.9.1
