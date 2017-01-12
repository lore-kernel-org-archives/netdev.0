From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: replace skb_tx_hash with fallback
Date: Thu, 12 Jan 2017 10:46:06 -0800
Message-ID: <20170112184606.GA5503@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0057.outbound.protection.outlook.com ([104.47.38.57]:20274
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750919AbdALSrK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 13:47:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Use fallback instead of skb_tx_hash for selecting txq

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 10 ++--------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 11 ++---------
 2 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b8b579d..90f000f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2231,15 +2231,9 @@ static void if_cfg_callback(struct octeon_device *oct,
  */
 static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 		    void *accel_priv __attribute__((unused)),
-		    select_queue_fallback_t fallback __attribute__((unused)))
+		    select_queue_fallback_t fallback)
 {
-	u32 qindex = 0;
-	struct lio *lio;
-
-	lio = GET_LIO(dev);
-	qindex = skb_tx_hash(dev, skb);
-
-	return (u16)(qindex % (lio->linfo.num_txpciq));
+	return fallback(dev, skb);
 }
 
 /** Routine to push packets arriving on Octeon interface upto network layer.
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index ad2e72d..a7478eb 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1463,16 +1463,9 @@ static void if_cfg_callback(struct octeon_device *oct,
  */
 static u16 select_q(struct net_device *dev, struct sk_buff *skb,
 		    void *accel_priv __attribute__((unused)),
-		    select_queue_fallback_t fallback __attribute__((unused)))
+		    select_queue_fallback_t fallback)
 {
-	struct lio *lio;
-	u32 qindex;
-
-	lio = GET_LIO(dev);
-
-	qindex = skb_tx_hash(dev, skb);
-
-	return (u16)(qindex % (lio->linfo.num_txpciq));
+	return fallback(dev, skb);
 }
 
 /** Routine to push packets arriving on Octeon interface upto network layer.
