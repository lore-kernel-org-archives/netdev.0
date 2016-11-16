From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] be2net: do not call napi_hash_del()
Date: Wed, 16 Nov 2016 06:12:42 -0800
Message-ID: <1479305562.8455.176.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33879 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbcKPOMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:12:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so14475384pgc.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:12:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() before netif_napi_del() is dangerous
if a synchronize_rcu() is not enforced before NAPI struct freeing.

Lets leave this detail to core networking stack and feel
more comfortable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Sathya Perla <sathya.perla@broadcom.com>
Cc: Ajit Khaparde <ajit.khaparde@broadcom.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Cc: Somnath Kotur <somnath.kotur@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index cece8a08edca..93aa2939142a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2813,7 +2813,6 @@ static void be_evt_queues_destroy(struct be_adapter *adapter)
 		if (eqo->q.created) {
 			be_eq_clean(eqo);
 			be_cmd_q_destroy(adapter, &eqo->q, QTYPE_EQ);
-			napi_hash_del(&eqo->napi);
 			netif_napi_del(&eqo->napi);
 			free_cpumask_var(eqo->affinity_mask);
 		}
