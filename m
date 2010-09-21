From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 1/3] caif: Minor fixes in log prints.
Date: Tue, 21 Sep 2010 23:44:44 +0200
Message-ID: <1285105486-7649-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Sjur Braendeland <sjur.braendeland@stericsson.com>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:49296 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475Ab0IUVow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:44:52 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L9400AA89QQ8C70@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 23:44:50 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.92]) by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L9400IWQ9QPI2F1@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Tue, 21 Sep 2010 23:44:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.braendeland@stericsson.com>

Use pr_debug for flow control printouts, and refine an error printout.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |    8 ++------
 net/caif/cfcnfg.c      |    2 +-
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index fd1f5df..3943398 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -159,9 +159,7 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 		(unsigned)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
-		trace_printk("CAIF: %s(): "
-			"sending flow OFF (queue len = %d %d)\n",
-			__func__,
+		pr_debug("sending flow OFF (queue len = %d %d)\n",
 			atomic_read(&cf_sk->sk.sk_rmem_alloc),
 			sk_rcvbuf_lowwater(cf_sk));
 		set_rx_flow_off(cf_sk);
@@ -174,9 +172,7 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		return err;
 	if (!sk_rmem_schedule(sk, skb->truesize) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
-		trace_printk("CAIF: %s(): "
-			"sending flow OFF due to rmem_schedule\n",
-			__func__);
+		pr_debug("sending flow OFF due to rmem_schedule\n");
 		dbfs_atomic_inc(&cnt.num_rx_flow_off);
 		caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_OFF_REQ);
 	}
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index ef93a13..41adafd 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -197,7 +197,7 @@ int cfcnfg_disconn_adapt_layer(struct cfcnfg *cnfg, struct cflayer *adap_layer)
 	caif_assert(adap_layer != NULL);
 	channel_id = adap_layer->id;
 	if (adap_layer->dn == NULL || channel_id == 0) {
-		pr_err("adap_layer->id is 0\n");
+		pr_err("adap_layer->dn == NULL or adap_layer->id is 0\n");
 		ret = -ENOTCONN;
 		goto end;
 	}
-- 
1.6.3.3

