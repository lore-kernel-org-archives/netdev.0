From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix Smatch error
Date: Fri, 18 Aug 2017 13:07:19 -0700
Message-ID: <20170818200719.GA4685@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0064.outbound.protection.outlook.com ([104.47.32.64]:65456
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751687AbdHRUHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 16:07:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Fix Smatch error by not dereferencing iq pointer if it's NULL.

See http://marc.info/?l=kernel-janitors&m=150296723301129&w=2

Also, remove unnecessary parentheses.

Fixes: d314ac222829 ("liquidio: moved liquidio_napi_poll to lio_core.c")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index d4f0646..0e7896c 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -668,8 +668,8 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 
 #define MAX_REG_CNT  2000000U
 	/* force enable interrupt if reg cnts are high to avoid wraparound */
-	if (((work_done < budget) && (tx_done)) ||
-	    (iq->pkt_in_done >= MAX_REG_CNT) ||
+	if ((work_done < budget && tx_done) ||
+	    (iq && iq->pkt_in_done >= MAX_REG_CNT) ||
 	    (droq->pkt_count >= MAX_REG_CNT)) {
 		tx_done = 1;
 		napi_complete_done(napi, work_done);
-- 
1.8.3.1
