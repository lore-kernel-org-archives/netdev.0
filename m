From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: do not dereference pointer if it's NULL
Date: Tue, 7 Feb 2017 12:10:58 -0800
Message-ID: <20170207201058.GA8962@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>,
        <dan.carpenter@oracle.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0072.outbound.protection.outlook.com ([104.47.33.72]:47744
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753259AbdBGUtT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 15:49:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix smatch errors by not dereferencing iq pointer if it's NULL.

See http://marc.info/?l=kernel-janitors&m=148637299004834&w=2

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 2 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index c12cfa4..a3c7b99 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2447,7 +2447,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 
 	/* force enable interrupt if reg cnts are high to avoid wraparound */
 	if ((work_done < budget && tx_done) ||
-	    (iq->pkt_in_done >= MAX_REG_CNT) ||
+	    (iq && iq->pkt_in_done >= MAX_REG_CNT) ||
 	    (droq->pkt_count >= MAX_REG_CNT)) {
 		tx_done = 1;
 		napi_complete_done(napi, work_done);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 631f1c0f..0536cb9 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1632,7 +1632,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 
 	/* force enable interrupt if reg cnts are high to avoid wraparound */
 	if ((work_done < budget && tx_done) ||
-	    (iq->pkt_in_done >= MAX_REG_CNT) ||
+	    (iq && iq->pkt_in_done >= MAX_REG_CNT) ||
 	    (droq->pkt_count >= MAX_REG_CNT)) {
 		tx_done = 1;
 		napi_complete_done(napi, work_done);
