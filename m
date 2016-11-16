From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ixgbevf: fix invalid use of napi_hash_del()
Date: Wed, 16 Nov 2016 07:15:15 -0800
Message-ID: <1479309315.8455.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34467 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753992AbcKPPPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:15:20 -0500
Received: by mail-pg0-f68.google.com with SMTP id e9so14592551pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 07:15:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() before netif_napi_del() is dangerous
if a synchronize_rcu() is not enforced before NAPI struct freeing.

Lets leave this detail to core networking stack to get it right.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 7eaac3234049..30a26e624e5a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2511,9 +2511,6 @@ static int ixgbevf_alloc_q_vectors(struct ixgbevf_adapter *adapter)
 	while (q_idx) {
 		q_idx--;
 		q_vector = adapter->q_vector[q_idx];
-#ifdef CONFIG_NET_RX_BUSY_POLL
-		napi_hash_del(&q_vector->napi);
-#endif
 		netif_napi_del(&q_vector->napi);
 		kfree(q_vector);
 		adapter->q_vector[q_idx] = NULL;
