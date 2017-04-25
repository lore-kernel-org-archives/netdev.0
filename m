From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: move xdp_prog field in RX cache lines
Date: Tue, 25 Apr 2017 11:36:52 -0700
Message-ID: <1493145412.6453.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35289 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1947173AbdDYSg7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 14:36:59 -0400
Received: by mail-pf0-f194.google.com with SMTP id a188so11981700pfa.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:36:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

(struct net_device, xdp_prog) field should be moved in RX cache lines,
reducing latencies when a single packet is received on idle host,
since netif_elide_gro() needs it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 46d220c2bf92c9ce5e31beb2300838462ee89304..8c5c8cdc7b977250dab9cab2a508249eb3814e32 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1790,6 +1790,7 @@ struct net_device {
 	unsigned int		real_num_rx_queues;
 #endif
 
+	struct bpf_prog __rcu	*xdp_prog;
 	unsigned long		gro_flush_timeout;
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
@@ -1905,7 +1906,6 @@ struct net_device {
 	struct lock_class_key	*qdisc_tx_busylock;
 	struct lock_class_key	*qdisc_running_key;
 	bool			proto_down;
-	struct bpf_prog __rcu	*xdp_prog;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
