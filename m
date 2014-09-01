From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 11/12] be2net: define macro for_all_tx_queues_on_eq()
Date: Mon, 1 Sep 2014 11:54:23 +0530
Message-ID: <1409552664-15990-12-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22507 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbaIAGWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:22:00 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the for() loop that traverses all the TX queues on an EQ
with the macro for_all_tx_queues_on_eq(). With this expalnatory
name, the one line comment is not required anymore.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    4 ++++
 drivers/net/ethernet/emulex/benet/be_main.c |    6 +++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index d952ca2..a9f239a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -621,6 +621,10 @@ extern const struct ethtool_ops be_ethtool_ops;
 	for (i = eqo->idx, rxo = &adapter->rx_obj[i]; i < adapter->num_rx_qs;\
 		 i += adapter->num_evt_qs, rxo += adapter->num_evt_qs)
 
+#define for_all_tx_queues_on_eq(adapter, eqo, txo, i)			\
+	for (i = eqo->idx, txo = &adapter->tx_obj[i]; i < adapter->num_tx_qs;\
+		i += adapter->num_evt_qs, txo += adapter->num_evt_qs)
+
 #define is_mcc_eqo(eqo)			(eqo->idx == 0)
 #define mcc_eqo(adapter)		(&adapter->eq_obj[0])
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 53727ad..f3235d1 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2503,12 +2503,12 @@ int be_poll(struct napi_struct *napi, int budget)
 	struct be_adapter *adapter = eqo->adapter;
 	int max_work = 0, work, i, num_evts;
 	struct be_rx_obj *rxo;
+	struct be_tx_obj *txo;
 
 	num_evts = events_get(eqo);
 
-	/* Process all TXQs serviced by this EQ */
-	for (i = eqo->idx; i < adapter->num_tx_qs; i += adapter->num_evt_qs)
-		be_process_tx(adapter, &adapter->tx_obj[i], i);
+	for_all_tx_queues_on_eq(adapter, eqo, txo, i)
+		be_process_tx(adapter, txo, i);
 
 	if (be_lock_napi(eqo)) {
 		/* This loop will iterate twice for EQ0 in which
-- 
1.7.1
