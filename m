From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH net-next] be2net: Use dev_consume_skb_any() in the non-drop path
Date: Thu, 28 Aug 2014 08:53:16 -0700 (PDT)
Message-ID: <20140828155316.5AE982900409@tardy>
Cc: <davem@davemloft.net>, <sathya.perla@emulex.com>,
	<subbu.seetharaman@emulex.com>, <ajit.khaparde@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:17634 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbaH1PxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 11:53:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

The be2net driver was still using dev_kfree_skb_any() in a "normal"
skb freeing path.  This rather clutters perf top -G -e skb_kfree_skb
profiling.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Briefly beaten-on with some netperf TCP_RR tests, but not tried with 
perf because I'm too clueless to get the 3.17.0-rc1 perf and all it 
seems to want onto my "Precise" test system :(

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 93ff8ef..42e9cea 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1991,7 +1991,7 @@ static u16 be_tx_compl_process(struct be_adapter *adapter,
 		queue_tail_inc(txq);
 	} while (cur_index != last_index);
 
-	dev_kfree_skb_any(sent_skb);
+	dev_consume_skb_any(sent_skb);
 	return num_wrbs;
 }
 
