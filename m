From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 4/7] net: replace NIPQUAD() in net/*/
Date: Thu, 30 Oct 2008 17:13:46 -0700
Message-ID: <1225412026.5574.35.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:38945 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbYJaANw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:13:52 -0400
Received: by rv-out-0506.google.com with SMTP id k40so905351rvb.1
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:13:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using NIPQUAD() with NIPQUAD_FMT, %d.%d.%d.%d or %u.%u.%u.%u
can be replaced with %pI4

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/atm/clip.c                           |    4 ++--
 net/atm/mpc.c                            |   26 ++++++++++++++------------
 net/atm/mpoa_caches.c                    |   18 +++++++++++-------
 net/bridge/netfilter/ebt_log.c           |   12 ++++--------
 net/dccp/ipv4.c                          |    8 +++-----
 net/dccp/probe.c                         |   12 ++++++------
 net/netlabel/netlabel_addrlist.c         |    2 +-
 net/rxrpc/af_rxrpc.c                     |    4 ++--
 net/rxrpc/ar-error.c                     |    3 +--
 net/rxrpc/ar-local.c                     |   16 ++++++++--------
 net/rxrpc/ar-peer.c                      |    8 ++++----
 net/rxrpc/ar-proc.c                      |   16 ++++++++--------
 net/rxrpc/ar-transport.c                 |   12 ++++++------
 net/rxrpc/rxkad.c                        |    2 +-
 net/sctp/protocol.c                      |   18 ++++++++----------
 net/sctp/sm_statefuns.c                  |    5 ++---
 net/sunrpc/clnt.c                        |    4 ++--
 net/sunrpc/rpcb_clnt.c                   |   11 +++++------
 net/sunrpc/svcauth_unix.c                |   17 ++++-------------
 net/sunrpc/svcsock.c                     |    6 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   12 ++++++------
 net/sunrpc/xprtrdma/transport.c          |   14 +++++++-------
 net/sunrpc/xprtrdma/verbs.c              |   14 ++++++--------
 net/sunrpc/xprtsock.c                    |   15 +++++++--------
 net/xfrm/xfrm_policy.c                   |    6 ++----
 net/xfrm/xfrm_state.c                    |   12 ++++--------
 26 files changed, 127 insertions(+), 150 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 5b5b963..2d33a83 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -822,8 +822,8 @@ static void atmarp_info(struct seq_file *seq, struct net_device *dev,
 	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
 		   dev->name, svc ? "SVC" : "PVC", llc ? "LLC" : "NULL", exp);
 
-	off = scnprintf(buf, sizeof(buf) - 1, "%d.%d.%d.%d",
-			NIPQUAD(entry->ip));
+	off = scnprintf(buf, sizeof(buf) - 1, "%pI4",
+			&entry->ip);
 	while (off < 16)
 		buf[off++] = ' ';
 	buf[off] = '\0';
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 11b16d1..010b1d2 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -232,8 +232,8 @@ void atm_mpoa_disp_qos(struct seq_file *m)
 	seq_printf(m, "IP address\n  TX:max_pcr pcr     min_pcr max_cdv max_sdu\n  RX:max_pcr pcr     min_pcr max_cdv max_sdu\n");
 
 	while (qos != NULL) {
-		seq_printf(m, "%u.%u.%u.%u\n     %-7d %-7d %-7d %-7d %-7d\n     %-7d %-7d %-7d %-7d %-7d\n",
-				NIPQUAD(qos->ipaddr),
+		seq_printf(m, "%pI4\n     %-7d %-7d %-7d %-7d %-7d\n     %-7d %-7d %-7d %-7d %-7d\n",
+				&qos->ipaddr,
 				qos->qos.txtp.max_pcr, qos->qos.txtp.pcr, qos->qos.txtp.min_pcr, qos->qos.txtp.max_cdv, qos->qos.txtp.max_sdu,
 				qos->qos.rxtp.max_pcr, qos->qos.rxtp.pcr, qos->qos.rxtp.min_pcr, qos->qos.rxtp.max_cdv, qos->qos.rxtp.max_sdu);
 		qos = qos->next;
@@ -595,8 +595,8 @@ static int atm_mpoa_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 			if (in_entry != NULL) mpc->in_ops->put(in_entry);
 			return -EINVAL;
 		}
-		printk("mpoa: (%s) mpc_vcc_attach: attaching ingress SVC, entry = %u.%u.%u.%u\n",
-		       mpc->dev->name, NIPQUAD(in_entry->ctrl_info.in_dst_ip));
+		printk("mpoa: (%s) mpc_vcc_attach: attaching ingress SVC, entry = %pI4\n",
+		       mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
 		in_entry->shortcut = vcc;
 		mpc->in_ops->put(in_entry);
 	} else {
@@ -627,8 +627,8 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 	dprintk("mpoa: (%s) mpc_vcc_close:\n", dev->name);
 	in_entry = mpc->in_ops->get_by_vcc(vcc, mpc);
 	if (in_entry) {
-		dprintk("mpoa: (%s) mpc_vcc_close: ingress SVC closed ip = %u.%u.%u.%u\n",
-		       mpc->dev->name, NIPQUAD(in_entry->ctrl_info.in_dst_ip));
+		dprintk("mpoa: (%s) mpc_vcc_close: ingress SVC closed ip = %pI4\n",
+		       mpc->dev->name, &in_entry->ctrl_info.in_dst_ip);
 		in_entry->shortcut = NULL;
 		mpc->in_ops->put(in_entry);
 	}
@@ -1098,7 +1098,8 @@ static void check_qos_and_open_shortcut(struct k_message *msg, struct mpoa_clien
 				    entry->shortcut = eg_entry->shortcut;
 		}
 		if(entry->shortcut){
-			dprintk("mpoa: (%s) using egress SVC to reach %u.%u.%u.%u\n",client->dev->name, NIPQUAD(dst_ip));
+			dprintk("mpoa: (%s) using egress SVC to reach %pI4\n",
+				client->dev->name, &dst_ip);
 			client->eg_ops->put(eg_entry);
 			return;
 		}
@@ -1123,7 +1124,8 @@ static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	__be32 dst_ip = msg->content.in_info.in_dst_ip;
 	in_cache_entry *entry = mpc->in_ops->get(dst_ip, mpc);
 
-	dprintk("mpoa: (%s) MPOA_res_reply_rcvd: ip %u.%u.%u.%u\n", mpc->dev->name, NIPQUAD(dst_ip));
+	dprintk("mpoa: (%s) MPOA_res_reply_rcvd: ip %pI4\n",
+		mpc->dev->name, &dst_ip);
 	ddprintk("mpoa: (%s) MPOA_res_reply_rcvd() entry = %p", mpc->dev->name, entry);
 	if(entry == NULL){
 		printk("\nmpoa: (%s) ARGH, received res. reply for an entry that doesn't exist.\n", mpc->dev->name);
@@ -1171,14 +1173,14 @@ static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	in_cache_entry *entry = mpc->in_ops->get_with_mask(dst_ip, mpc, mask);
 
 	if(entry == NULL){
-		printk("mpoa: (%s) ingress_purge_rcvd: purge for a non-existing entry, ", mpc->dev->name);
-		printk("ip = %u.%u.%u.%u\n", NIPQUAD(dst_ip));
+		printk("mpoa: (%s) ingress_purge_rcvd: purge for a non-existing entry, ip = %pI4\n",
+		       mpc->dev->name, &dst_ip);
 		return;
 	}
 
 	do {
-		dprintk("mpoa: (%s) ingress_purge_rcvd: removing an ingress entry, ip = %u.%u.%u.%u\n" ,
-			mpc->dev->name, NIPQUAD(dst_ip));
+		dprintk("mpoa: (%s) ingress_purge_rcvd: removing an ingress entry, ip = %pI4\n",
+			mpc->dev->name, &dst_ip);
 		write_lock_bh(&mpc->ingress_lock);
 		mpc->in_ops->remove_entry(entry, mpc);
 		write_unlock_bh(&mpc->ingress_lock);
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index 24799e3..4504a4b 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -94,7 +94,7 @@ static in_cache_entry *in_cache_add_entry(__be32 dst_ip,
 		return NULL;
 	}
 
-	dprintk("mpoa: mpoa_caches.c: adding an ingress entry, ip = %u.%u.%u.%u\n", NIPQUAD(dst_ip));
+	dprintk("mpoa: mpoa_caches.c: adding an ingress entry, ip = %pI4\n", &dst_ip);
 
 	atomic_set(&entry->use, 1);
 	dprintk("mpoa: mpoa_caches.c: new_in_cache_entry: about to lock\n");
@@ -150,7 +150,8 @@ static int cache_hit(in_cache_entry *entry, struct mpoa_client *mpc)
 
 	if( entry->count > mpc->parameters.mpc_p1 &&
 	    entry->entry_state == INGRESS_INVALID){
-		dprintk("mpoa: (%s) mpoa_caches.c: threshold exceeded for ip %u.%u.%u.%u, sending MPOA res req\n", mpc->dev->name, NIPQUAD(entry->ctrl_info.in_dst_ip));
+		dprintk("mpoa: (%s) mpoa_caches.c: threshold exceeded for ip %pI4, sending MPOA res req\n",
+			mpc->dev->name, &entry->ctrl_info.in_dst_ip);
 		entry->entry_state = INGRESS_RESOLVING;
 		msg.type =  SND_MPOA_RES_RQST;
 		memcpy(msg.MPS_ctrl, mpc->mps_ctrl_addr, ATM_ESA_LEN );
@@ -184,7 +185,8 @@ static void in_cache_remove_entry(in_cache_entry *entry,
 	struct k_message msg;
 
 	vcc = entry->shortcut;
-	dprintk("mpoa: mpoa_caches.c: removing an ingress entry, ip = %u.%u.%u.%u\n",NIPQUAD(entry->ctrl_info.in_dst_ip));
+	dprintk("mpoa: mpoa_caches.c: removing an ingress entry, ip = %pI4\n",
+		&entry->ctrl_info.in_dst_ip);
 
 	if (entry->prev != NULL)
 		entry->prev->next = entry->next;
@@ -228,7 +230,8 @@ static void clear_count_and_expired(struct mpoa_client *client)
 		next_entry = entry->next;
 		if((now.tv_sec - entry->tv.tv_sec)
 		   > entry->ctrl_info.holding_time){
-			dprintk("mpoa: mpoa_caches.c: holding time expired, ip = %u.%u.%u.%u\n", NIPQUAD(entry->ctrl_info.in_dst_ip));
+			dprintk("mpoa: mpoa_caches.c: holding time expired, ip = %pI4\n",
+				&entry->ctrl_info.in_dst_ip);
 			client->in_ops->remove_entry(entry, client);
 		}
 		entry = next_entry;
@@ -453,7 +456,8 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg, struct mpoa_cli
 		return NULL;
 	}
 
-	dprintk("mpoa: mpoa_caches.c: adding an egress entry, ip = %u.%u.%u.%u, this should be our IP\n", NIPQUAD(msg->content.eg_info.eg_dst_ip));
+	dprintk("mpoa: mpoa_caches.c: adding an egress entry, ip = %pI4, this should be our IP\n",
+		&msg->content.eg_info.eg_dst_ip);
 
 	atomic_set(&entry->use, 1);
 	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry: about to lock\n");
@@ -469,8 +473,8 @@ static eg_cache_entry *eg_cache_add_entry(struct k_message *msg, struct mpoa_cli
 	do_gettimeofday(&(entry->tv));
 	entry->entry_state = EGRESS_RESOLVED;
 	dprintk("mpoa: mpoa_caches.c: new_eg_cache_entry cache_id %lu\n", ntohl(entry->ctrl_info.cache_id));
-	dprintk("mpoa: mpoa_caches.c: mps_ip = %u.%u.%u.%u\n",
-		NIPQUAD(entry->ctrl_info.mps_ip));
+	dprintk("mpoa: mpoa_caches.c: mps_ip = %pI4\n",
+		&entry->ctrl_info.mps_ip);
 	atomic_inc(&entry->use);
 
 	write_unlock_irq(&client->egress_lock);
diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
index 5e7cff3..d44cbf8 100644
--- a/net/bridge/netfilter/ebt_log.c
+++ b/net/bridge/netfilter/ebt_log.c
@@ -79,7 +79,6 @@ print_ports(const struct sk_buff *skb, uint8_t protocol, int offset)
 	}
 }
 
-#define myNIPQUAD(a) a[0], a[1], a[2], a[3]
 static void
 ebt_log_packet(u_int8_t pf, unsigned int hooknum,
    const struct sk_buff *skb, const struct net_device *in,
@@ -113,9 +112,8 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 			printk(" INCOMPLETE IP header");
 			goto out;
 		}
-		printk(" IP SRC=%u.%u.%u.%u IP DST=%u.%u.%u.%u, IP "
-		       "tos=0x%02X, IP proto=%d", NIPQUAD(ih->saddr),
-		       NIPQUAD(ih->daddr), ih->tos, ih->protocol);
+		printk(" IP SRC=%pI4 IP DST=%pI4, IP tos=0x%02X, IP proto=%d",
+		       &ih->saddr, &ih->daddr, ih->tos, ih->protocol);
 		print_ports(skb, ih->protocol, ih->ihl*4);
 		goto out;
 	}
@@ -175,12 +173,10 @@ ebt_log_packet(u_int8_t pf, unsigned int hooknum,
 			}
 			printk(" ARP MAC SRC=");
 			print_MAC(ap->mac_src);
-			printk(" ARP IP SRC=%u.%u.%u.%u",
-			       myNIPQUAD(ap->ip_src));
+			printk(" ARP IP SRC=%pI4", ap->ip_src);
 			printk(" ARP MAC DST=");
 			print_MAC(ap->mac_dst);
-			printk(" ARP IP DST=%u.%u.%u.%u",
-			       myNIPQUAD(ap->ip_dst));
+			printk(" ARP IP DST=%pI4", ap->ip_dst);
 		}
 	}
 out:
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index e3dfdda..01e3e02 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -792,12 +792,10 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 	DCCP_SKB_CB(skb)->dccpd_seq  = dccp_hdr_seq(dh);
 	DCCP_SKB_CB(skb)->dccpd_type = dh->dccph_type;
 
-	dccp_pr_debug("%8.8s "
-		      "src=%u.%u.%u.%u@%-5d "
-		      "dst=%u.%u.%u.%u@%-5d seq=%llu",
+	dccp_pr_debug("%8.8s src=%pI4@%-5d dst=%pI4@%-5d seq=%llu",
 		      dccp_packet_name(dh->dccph_type),
-		      NIPQUAD(iph->saddr), ntohs(dh->dccph_sport),
-		      NIPQUAD(iph->daddr), ntohs(dh->dccph_dport),
+		      &iph->saddr, ntohs(dh->dccph_sport),
+		      &iph->daddr, ntohs(dh->dccph_dport),
 		      (unsigned long long) DCCP_SKB_CB(skb)->dccpd_seq);
 
 	if (dccp_packet_without_ack(skb)) {
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 81368a7..49ba8d5 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -86,18 +86,18 @@ static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (port == 0 || ntohs(inet->dport) == port ||
 	    ntohs(inet->sport) == port) {
 		if (hctx)
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %u "
+			printl("%pI4:%u %pI4:%u %d %d %d %d %u "
 			       "%llu %llu %d\n",
-			       NIPQUAD(inet->saddr), ntohs(inet->sport),
-			       NIPQUAD(inet->daddr), ntohs(inet->dport), size,
+			       &inet->saddr, ntohs(inet->sport),
+			       &inet->daddr, ntohs(inet->dport), size,
 			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
 			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
 			       hctx->ccid3hctx_x_recv >> 6,
 			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
 		else
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
-			       NIPQUAD(inet->saddr), ntohs(inet->sport),
-			       NIPQUAD(inet->daddr), ntohs(inet->dport), size);
+			printl("%pI4:%u %pI4:%u %d\n",
+			       &inet->saddr, ntohs(inet->sport),
+			       &inet->daddr, ntohs(inet->dport), size);
 	}
 
 	jprobe_return();
diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index 8b1c58b..66771c8 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -336,7 +336,7 @@ void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
 
 	if (dev != NULL)
 		audit_log_format(audit_buf, " netif=%s", dev);
-	audit_log_format(audit_buf, " %s=" NIPQUAD_FMT, dir, NIPQUAD(addr));
+	audit_log_format(audit_buf, " %s=%pI4", dir, &addr);
 	if (mask_val != 0xffffffff) {
 		u32 mask_len = 0;
 		while (mask_val > 0) {
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 32e4891..d7d2bed 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -96,9 +96,9 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 
 	switch (srx->transport.family) {
 	case AF_INET:
-		_debug("INET: %x @ %u.%u.%u.%u",
+		_debug("INET: %x @ %pI4",
 		       ntohs(srx->transport.sin.sin_port),
-		       NIPQUAD(srx->transport.sin.sin_addr));
+		       &srx->transport.sin.sin_addr);
 		if (srx->transport_len > 8)
 			memset((void *)&srx->transport + 8, 0,
 			       srx->transport_len - 8);
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 6cb3e88..d4d1ae2 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -49,8 +49,7 @@ void rxrpc_UDP_error_report(struct sock *sk)
 	addr = *(__be32 *)(skb_network_header(skb) + serr->addr_offset);
 	port = serr->port;
 
-	_net("Rx UDP Error from "NIPQUAD_FMT":%hu",
-	     NIPQUAD(addr), ntohs(port));
+	_net("Rx UDP Error from %pI4:%hu", &addr, ntohs(port));
 	_debug("Msg l:%d d:%d", skb->len, skb->data_len);
 
 	peer = rxrpc_find_peer(local, addr, port);
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index f3a2bd7..807535f 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -131,10 +131,10 @@ struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
 	struct rxrpc_local *local;
 	int ret;
 
-	_enter("{%d,%u,%u.%u.%u.%u+%hu}",
+	_enter("{%d,%u,%pI4+%hu}",
 	       srx->transport_type,
 	       srx->transport.family,
-	       NIPQUAD(srx->transport.sin.sin_addr),
+	       &srx->transport.sin.sin_addr,
 	       ntohs(srx->transport.sin.sin_port));
 
 	down_write(&rxrpc_local_sem);
@@ -143,10 +143,10 @@ struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
 	read_lock_bh(&rxrpc_local_lock);
 
 	list_for_each_entry(local, &rxrpc_locals, link) {
-		_debug("CMP {%d,%u,%u.%u.%u.%u+%hu}",
+		_debug("CMP {%d,%u,%pI4+%hu}",
 		       local->srx.transport_type,
 		       local->srx.transport.family,
-		       NIPQUAD(local->srx.transport.sin.sin_addr),
+		       &local->srx.transport.sin.sin_addr,
 		       ntohs(local->srx.transport.sin.sin_port));
 
 		if (local->srx.transport_type != srx->transport_type ||
@@ -188,11 +188,11 @@ struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
 
 	up_write(&rxrpc_local_sem);
 
-	_net("LOCAL new %d {%d,%u,%u.%u.%u.%u+%hu}",
+	_net("LOCAL new %d {%d,%u,%pI4+%hu}",
 	     local->debug_id,
 	     local->srx.transport_type,
 	     local->srx.transport.family,
-	     NIPQUAD(local->srx.transport.sin.sin_addr),
+	     &local->srx.transport.sin.sin_addr,
 	     ntohs(local->srx.transport.sin.sin_port));
 
 	_leave(" = %p [new]", local);
@@ -203,11 +203,11 @@ found_local:
 	read_unlock_bh(&rxrpc_local_lock);
 	up_write(&rxrpc_local_sem);
 
-	_net("LOCAL old %d {%d,%u,%u.%u.%u.%u+%hu}",
+	_net("LOCAL old %d {%d,%u,%pI4+%hu}",
 	     local->debug_id,
 	     local->srx.transport_type,
 	     local->srx.transport.family,
-	     NIPQUAD(local->srx.transport.sin.sin_addr),
+	     &local->srx.transport.sin.sin_addr,
 	     ntohs(local->srx.transport.sin.sin_port));
 
 	_leave(" = %p [reuse]", local);
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index 2abe208..edc026c 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -123,10 +123,10 @@ struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
 	const char *new = "old";
 	int usage;
 
-	_enter("{%d,%d,%u.%u.%u.%u+%hu}",
+	_enter("{%d,%d,%pI4+%hu}",
 	       srx->transport_type,
 	       srx->transport_len,
-	       NIPQUAD(srx->transport.sin.sin_addr),
+	       &srx->transport.sin.sin_addr,
 	       ntohs(srx->transport.sin.sin_port));
 
 	/* search the peer list first */
@@ -177,12 +177,12 @@ struct rxrpc_peer *rxrpc_get_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
 	new = "new";
 
 success:
-	_net("PEER %s %d {%d,%u,%u.%u.%u.%u+%hu}",
+	_net("PEER %s %d {%d,%u,%pI4+%hu}",
 	     new,
 	     peer->debug_id,
 	     peer->srx.transport_type,
 	     peer->srx.transport.family,
-	     NIPQUAD(peer->srx.transport.sin.sin_addr),
+	     &peer->srx.transport.sin.sin_addr,
 	     ntohs(peer->srx.transport.sin.sin_port));
 
 	_leave(" = %p {u=%d}", peer, atomic_read(&peer->usage));
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/ar-proc.c
index 017322e..38047f7 100644
--- a/net/rxrpc/ar-proc.c
+++ b/net/rxrpc/ar-proc.c
@@ -61,12 +61,12 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	call = list_entry(v, struct rxrpc_call, link);
 	trans = call->conn->trans;
 
-	sprintf(lbuff, NIPQUAD_FMT":%u",
-		NIPQUAD(trans->local->srx.transport.sin.sin_addr),
+	sprintf(lbuff, "%pI4:%u",
+		&trans->local->srx.transport.sin.sin_addr,
 		ntohs(trans->local->srx.transport.sin.sin_port));
 
-	sprintf(rbuff, NIPQUAD_FMT":%u",
-		NIPQUAD(trans->peer->srx.transport.sin.sin_addr),
+	sprintf(rbuff, "%pI4:%u",
+		&trans->peer->srx.transport.sin.sin_addr,
 		ntohs(trans->peer->srx.transport.sin.sin_port));
 
 	seq_printf(seq,
@@ -144,12 +144,12 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	conn = list_entry(v, struct rxrpc_connection, link);
 	trans = conn->trans;
 
-	sprintf(lbuff, NIPQUAD_FMT":%u",
-		NIPQUAD(trans->local->srx.transport.sin.sin_addr),
+	sprintf(lbuff, "%pI4:%u",
+		&trans->local->srx.transport.sin.sin_addr,
 		ntohs(trans->local->srx.transport.sin.sin_port));
 
-	sprintf(rbuff, NIPQUAD_FMT":%u",
-		NIPQUAD(trans->peer->srx.transport.sin.sin_addr),
+	sprintf(rbuff, "%pI4:%u",
+		&trans->peer->srx.transport.sin.sin_addr,
 		ntohs(trans->peer->srx.transport.sin.sin_port));
 
 	seq_printf(seq,
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 64069c8..0936e1a 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -78,10 +78,10 @@ struct rxrpc_transport *rxrpc_get_transport(struct rxrpc_local *local,
 	const char *new = "old";
 	int usage;
 
-	_enter("{%u.%u.%u.%u+%hu},{%u.%u.%u.%u+%hu},",
-	       NIPQUAD(local->srx.transport.sin.sin_addr),
+	_enter("{%pI4+%hu},{%pI4+%hu},",
+	       &local->srx.transport.sin.sin_addr,
 	       ntohs(local->srx.transport.sin.sin_port),
-	       NIPQUAD(peer->srx.transport.sin.sin_addr),
+	       &peer->srx.transport.sin.sin_addr,
 	       ntohs(peer->srx.transport.sin.sin_port));
 
 	/* search the transport list first */
@@ -149,10 +149,10 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *local,
 {
 	struct rxrpc_transport *trans;
 
-	_enter("{%u.%u.%u.%u+%hu},{%u.%u.%u.%u+%hu},",
-	       NIPQUAD(local->srx.transport.sin.sin_addr),
+	_enter("{%pI4+%hu},{%pI4+%hu},",
+	       &local->srx.transport.sin.sin_addr,
 	       ntohs(local->srx.transport.sin.sin_port),
-	       NIPQUAD(peer->srx.transport.sin.sin_addr),
+	       &peer->srx.transport.sin.sin_addr,
 	       ntohs(peer->srx.transport.sin.sin_port));
 
 	/* search the transport list */
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ba3f6e4..ef8f910 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -897,7 +897,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	/* get the IPv4 address of the entity that requested the ticket */
 	memcpy(&addr, p, sizeof(addr));
 	p += 4;
-	_debug("KIV ADDR : "NIPQUAD_FMT, NIPQUAD(addr));
+	_debug("KIV ADDR : %pI4", &addr);
 
 	/* get the session key from the ticket */
 	memcpy(&key, p, sizeof(key));
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 0b65354..a8ca743 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -482,9 +482,8 @@ static struct dst_entry *sctp_v4_get_dst(struct sctp_association *asoc,
 	if (saddr)
 		fl.fl4_src = saddr->v4.sin_addr.s_addr;
 
-	SCTP_DEBUG_PRINTK("%s: DST:%u.%u.%u.%u, SRC:%u.%u.%u.%u - ",
-			  __func__, NIPQUAD(fl.fl4_dst),
-			  NIPQUAD(fl.fl4_src));
+	SCTP_DEBUG_PRINTK("%s: DST:%pI4, SRC:%pI4 - ",
+			  __func__, &fl.fl4_dst, &fl.fl4_src);
 
 	if (!ip_route_output_key(&init_net, &rt, &fl)) {
 		dst = &rt->u.dst;
@@ -540,8 +539,8 @@ out_unlock:
 	rcu_read_unlock();
 out:
 	if (dst)
-		SCTP_DEBUG_PRINTK("rt_dst:%u.%u.%u.%u, rt_src:%u.%u.%u.%u\n",
-				  NIPQUAD(rt->rt_dst), NIPQUAD(rt->rt_src));
+		SCTP_DEBUG_PRINTK("rt_dst:%pI4, rt_src:%pI4\n",
+				  &rt->rt_dst, &rt->rt_src);
 	else
 		SCTP_DEBUG_PRINTK("NO ROUTE\n");
 
@@ -646,7 +645,7 @@ static void sctp_v4_addr_v4map(struct sctp_sock *sp, union sctp_addr *addr)
 /* Dump the v4 addr to the seq file. */
 static void sctp_v4_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 {
-	seq_printf(seq, "%d.%d.%d.%d ", NIPQUAD(addr->v4.sin_addr));
+	seq_printf(seq, "%pI4 ", &addr->v4.sin_addr);
 }
 
 static void sctp_v4_ecn_capable(struct sock *sk)
@@ -866,11 +865,10 @@ static inline int sctp_v4_xmit(struct sk_buff *skb,
 {
 	struct inet_sock *inet = inet_sk(skb->sk);
 
-	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, "
-			  "src:%u.%u.%u.%u, dst:%u.%u.%u.%u\n",
+	SCTP_DEBUG_PRINTK("%s: skb:%p, len:%d, src:%pI4, dst:%pI4\n",
 			  __func__, skb, skb->len,
-			  NIPQUAD(skb->rtable->rt_src),
-			  NIPQUAD(skb->rtable->rt_dst));
+			  &skb->rtable->rt_src,
+			  &skb->rtable->rt_dst);
 
 	inet->pmtudisc = transport->param_flags & SPP_PMTUD_ENABLE ?
 			 IP_PMTUDISC_DO : IP_PMTUDISC_DONT;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d07b484..9f2a3eb 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1130,11 +1130,10 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 		} else {
 			if (net_ratelimit())
 				printk(KERN_WARNING
-				    "%s association %p could not find address "
-				    NIPQUAD_FMT "\n",
+				    "%s association %p could not find address %pI4\n",
 				    __func__,
 				    asoc,
-				    NIPQUAD(from_addr.v4.sin_addr.s_addr));
+				    &from_addr.v4.sin_addr.s_addr);
 		}
 		return SCTP_DISPOSITION_DISCARD;
 	}
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8f06749..3ca5183 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -271,8 +271,8 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		case AF_INET: {
 			struct sockaddr_in *sin =
 					(struct sockaddr_in *)args->address;
-			snprintf(servername, sizeof(servername), NIPQUAD_FMT,
-				 NIPQUAD(sin->sin_addr.s_addr));
+			snprintf(servername, sizeof(servername), "%pI4",
+				 &sin->sin_addr.s_addr);
 			break;
 		}
 		case AF_INET6: {
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4c8adad..03ae007 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -270,10 +270,9 @@ static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
 	char buf[32];
 
 	/* Construct AF_INET universal address */
-	snprintf(buf, sizeof(buf),
-			NIPQUAD_FMT".%u.%u",
-			NIPQUAD(address_to_register->sin_addr.s_addr),
-			port >> 8, port & 0xff);
+	snprintf(buf, sizeof(buf), "%pI4.%u.%u",
+		 &address_to_register->sin_addr.s_addr,
+		 port >> 8, port & 0xff);
 	map->r_addr = buf;
 
 	dprintk("RPC:       %sregistering [%u, %u, %s, '%s'] with "
@@ -422,8 +421,8 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 	struct rpc_clnt	*rpcb_clnt;
 	int status;
 
-	dprintk("RPC:       %s(" NIPQUAD_FMT ", %u, %u, %d)\n",
-		__func__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
+	dprintk("RPC:       %s(%pI4, %u, %u, %d)\n",
+		__func__, &sin->sin_addr.s_addr, prog, vers, prot);
 
 	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
 				sizeof(*sin), prot, RPCBVERS_2);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 16f714a..82240e6 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -162,11 +162,7 @@ static void ip_map_request(struct cache_detail *cd,
 	struct ip_map *im = container_of(h, struct ip_map, h);
 
 	if (ipv6_addr_v4mapped(&(im->m_addr))) {
-		snprintf(text_addr, 20, NIPQUAD_FMT,
-				ntohl(im->m_addr.s6_addr32[3]) >> 24 & 0xff,
-				ntohl(im->m_addr.s6_addr32[3]) >> 16 & 0xff,
-				ntohl(im->m_addr.s6_addr32[3]) >>  8 & 0xff,
-				ntohl(im->m_addr.s6_addr32[3]) >>  0 & 0xff);
+		snprintf(text_addr, 20, "%pI4", &im->m_addr.s6_addr32[3]);
 	} else {
 		snprintf(text_addr, 40, "%pI6", &im->m_addr);
 	}
@@ -208,7 +204,7 @@ static int ip_map_parse(struct cache_detail *cd,
 	len = qword_get(&mesg, buf, mlen);
 	if (len <= 0) return -EINVAL;
 
-	if (sscanf(buf, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) == 4) {
+	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) == 4) {
 		addr.s6_addr32[0] = 0;
 		addr.s6_addr32[1] = 0;
 		addr.s6_addr32[2] = htonl(0xffff);
@@ -278,13 +274,8 @@ static int ip_map_show(struct seq_file *m,
 		dom = im->m_client->h.name;
 
 	if (ipv6_addr_v4mapped(&addr)) {
-		seq_printf(m, "%s " NIPQUAD_FMT " %s\n",
-			im->m_class,
-			ntohl(addr.s6_addr32[3]) >> 24 & 0xff,
-			ntohl(addr.s6_addr32[3]) >> 16 & 0xff,
-			ntohl(addr.s6_addr32[3]) >>  8 & 0xff,
-			ntohl(addr.s6_addr32[3]) >>  0 & 0xff,
-			dom);
+		seq_printf(m, "%s %pI4 %s\n",
+			im->m_class, &addr.s6_addr32[3], dom);
 	} else {
 		seq_printf(m, "%s %pI6 %s\n", im->m_class, &addr, dom);
 	}
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 95293f5..6f7d1f2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -250,10 +250,10 @@ static int one_sock_name(char *buf, struct svc_sock *svsk)
 
 	switch(svsk->sk_sk->sk_family) {
 	case AF_INET:
-		len = sprintf(buf, "ipv4 %s %u.%u.%u.%u %d\n",
-			      svsk->sk_sk->sk_protocol==IPPROTO_UDP?
+		len = sprintf(buf, "ipv4 %s %pI4 %d\n",
+			      svsk->sk_sk->sk_protocol == IPPROTO_UDP ?
 			      "udp" : "tcp",
-			      NIPQUAD(inet_sk(svsk->sk_sk)->rcv_saddr),
+			      &inet_sk(svsk->sk_sk)->rcv_saddr,
 			      inet_sk(svsk->sk_sk)->num);
 		break;
 	default:
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6fb493c..f8500f0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -1048,21 +1048,21 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 
 	dprintk("svcrdma: new connection %p accepted with the following "
 		"attributes:\n"
-		"    local_ip        : %d.%d.%d.%d\n"
+		"    local_ip        : %pI4\n"
 		"    local_port	     : %d\n"
-		"    remote_ip       : %d.%d.%d.%d\n"
+		"    remote_ip       : %pI4\n"
 		"    remote_port     : %d\n"
 		"    max_sge         : %d\n"
 		"    sq_depth        : %d\n"
 		"    max_requests    : %d\n"
 		"    ord             : %d\n",
 		newxprt,
-		NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
-			 route.addr.src_addr)->sin_addr.s_addr),
+		&((struct sockaddr_in *)&newxprt->sc_cm_id->
+			 route.addr.src_addr)->sin_addr.s_addr,
 		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
 		       route.addr.src_addr)->sin_port),
-		NIPQUAD(((struct sockaddr_in *)&newxprt->sc_cm_id->
-			 route.addr.dst_addr)->sin_addr.s_addr),
+		&((struct sockaddr_in *)&newxprt->sc_cm_id->
+			 route.addr.dst_addr)->sin_addr.s_addr,
 		ntohs(((struct sockaddr_in *)&newxprt->sc_cm_id->
 		       route.addr.dst_addr)->sin_port),
 		newxprt->sc_max_sge,
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 9839c3d..1dd6123 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -174,7 +174,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 
 	buf = kzalloc(20, GFP_KERNEL);
 	if (buf)
-		snprintf(buf, 20, NIPQUAD_FMT, NIPQUAD(addr->sin_addr.s_addr));
+		snprintf(buf, 20, "%pI4", &addr->sin_addr.s_addr);
 	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
 
 	buf = kzalloc(8, GFP_KERNEL);
@@ -186,8 +186,8 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 
 	buf = kzalloc(48, GFP_KERNEL);
 	if (buf)
-		snprintf(buf, 48, "addr="NIPQUAD_FMT" port=%u proto=%s",
-			NIPQUAD(addr->sin_addr.s_addr),
+		snprintf(buf, 48, "addr=%pI4 port=%u proto=%s",
+			&addr->sin_addr.s_addr,
 			ntohs(addr->sin_port), "rdma");
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
 
@@ -204,8 +204,8 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 
 	buf = kzalloc(30, GFP_KERNEL);
 	if (buf)
-		snprintf(buf, 30, NIPQUAD_FMT".%u.%u",
-			NIPQUAD(addr->sin_addr.s_addr),
+		snprintf(buf, 30, "%pI4.%u.%u",
+			&addr->sin_addr.s_addr,
 			ntohs(addr->sin_port) >> 8,
 			ntohs(addr->sin_port) & 0xff);
 	xprt->address_strings[RPC_DISPLAY_UNIVERSAL_ADDR] = buf;
@@ -369,8 +369,8 @@ xprt_setup_rdma(struct xprt_create *args)
 	if (ntohs(sin->sin_port) != 0)
 		xprt_set_bound(xprt);
 
-	dprintk("RPC:       %s: %u.%u.%u.%u:%u\n", __func__,
-			NIPQUAD(sin->sin_addr.s_addr), ntohs(sin->sin_port));
+	dprintk("RPC:       %s: %pI4:%u\n",
+		__func__, &sin->sin_addr.s_addr, ntohs(sin->sin_port));
 
 	/* Set max requests */
 	cdata.max_requests = xprt->max_reqs;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a5fef5e..78f7f72 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -323,12 +323,11 @@ rpcrdma_conn_upcall(struct rdma_cm_id *id, struct rdma_cm_event *event)
 	case RDMA_CM_EVENT_DEVICE_REMOVAL:
 		connstate = -ENODEV;
 connected:
-		dprintk("RPC:       %s: %s: %u.%u.%u.%u:%u"
-			" (ep 0x%p event 0x%x)\n",
+		dprintk("RPC:       %s: %s: %pI4:%u (ep 0x%p event 0x%x)\n",
 			__func__,
 			(event->event <= 11) ? conn[event->event] :
 						"unknown connection error",
-			NIPQUAD(addr->sin_addr.s_addr),
+			&addr->sin_addr.s_addr,
 			ntohs(addr->sin_port),
 			ep, event->event);
 		atomic_set(&rpcx_to_rdmax(ep->rep_xprt)->rx_buf.rb_credits, 1);
@@ -348,18 +347,17 @@ connected:
 	if (connstate == 1) {
 		int ird = attr.max_dest_rd_atomic;
 		int tird = ep->rep_remote_cma.responder_resources;
-		printk(KERN_INFO "rpcrdma: connection to %u.%u.%u.%u:%u "
+		printk(KERN_INFO "rpcrdma: connection to %pI4:%u "
 			"on %s, memreg %d slots %d ird %d%s\n",
-			NIPQUAD(addr->sin_addr.s_addr),
+			&addr->sin_addr.s_addr,
 			ntohs(addr->sin_port),
 			ia->ri_id->device->name,
 			ia->ri_memreg_strategy,
 			xprt->rx_buf.rb_max_requests,
 			ird, ird < 4 && ird < tird / 2 ? " (low!)" : "");
 	} else if (connstate < 0) {
-		printk(KERN_INFO "rpcrdma: connection to %u.%u.%u.%u:%u "
-			"closed (%d)\n",
-			NIPQUAD(addr->sin_addr.s_addr),
+		printk(KERN_INFO "rpcrdma: connection to %pI4:%u closed (%d)\n",
+			&addr->sin_addr.s_addr,
 			ntohs(addr->sin_port),
 			connstate);
 	}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f9ce3c9..f31087a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -283,8 +283,7 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(20, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 20, NIPQUAD_FMT,
-				NIPQUAD(addr->sin_addr.s_addr));
+		snprintf(buf, 20, "pI4", &addr->sin_addr.s_addr);
 	}
 	xprt->address_strings[RPC_DISPLAY_ADDR] = buf;
 
@@ -299,8 +298,8 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(48, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 48, "addr="NIPQUAD_FMT" port=%u proto=%s",
-			NIPQUAD(addr->sin_addr.s_addr),
+		snprintf(buf, 48, "addr=%pI4 port=%u proto=%s",
+			&addr->sin_addr.s_addr,
 			ntohs(addr->sin_port),
 			protocol);
 	}
@@ -322,8 +321,8 @@ static void xs_format_ipv4_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(30, GFP_KERNEL);
 	if (buf) {
-		snprintf(buf, 30, NIPQUAD_FMT".%u.%u",
-				NIPQUAD(addr->sin_addr.s_addr),
+		snprintf(buf, 30, "%pI4.%u.%u",
+				&addr->sin_addr.s_addr,
 				ntohs(addr->sin_port) >> 8,
 				ntohs(addr->sin_port) & 0xff);
 	}
@@ -1374,8 +1373,8 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
 		if (port > last)
 			nloop++;
 	} while (err == -EADDRINUSE && nloop != 2);
-	dprintk("RPC:       %s "NIPQUAD_FMT":%u: %s (%d)\n",
-			__func__, NIPQUAD(myaddr.sin_addr),
+	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
+			__func__, &myaddr.sin_addr,
 			port, err ? "failed" : "ok", err);
 	return err;
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 80b13ee..530f710 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2455,13 +2455,11 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 
 	switch(sel->family) {
 	case AF_INET:
-		audit_log_format(audit_buf, " src=" NIPQUAD_FMT,
-				 NIPQUAD(sel->saddr.a4));
+		audit_log_format(audit_buf, " src=%pI4", &sel->saddr.a4);
 		if (sel->prefixlen_s != 32)
 			audit_log_format(audit_buf, " src_prefixlen=%d",
 					 sel->prefixlen_s);
-		audit_log_format(audit_buf, " dst=" NIPQUAD_FMT,
-				 NIPQUAD(sel->daddr.a4));
+		audit_log_format(audit_buf, " dst=%pI4", &sel->daddr.a4);
 		if (sel->prefixlen_d != 32)
 			audit_log_format(audit_buf, " dst_prefixlen=%d",
 					 sel->prefixlen_d);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 304eca4..cd9d917 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2109,10 +2109,8 @@ static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
 
 	switch(x->props.family) {
 	case AF_INET:
-		audit_log_format(audit_buf,
-				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
-				 NIPQUAD(x->props.saddr.a4),
-				 NIPQUAD(x->id.daddr.a4));
+		audit_log_format(audit_buf, " src=%pI4 dst=%pI4",
+				 &x->props.saddr.a4, &x->id.daddr.a4);
 		break;
 	case AF_INET6:
 		audit_log_format(audit_buf, " src=%pI6 dst=%pI6",
@@ -2132,10 +2130,8 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 	switch (family) {
 	case AF_INET:
 		iph4 = ip_hdr(skb);
-		audit_log_format(audit_buf,
-				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
-				 NIPQUAD(iph4->saddr),
-				 NIPQUAD(iph4->daddr));
+		audit_log_format(audit_buf, " src=%pI4 dst=%pI4",
+				 &iph4->saddr, &iph4->daddr);
 		break;
 	case AF_INET6:
 		iph6 = ipv6_hdr(skb);
-- 
1.6.0.3.756.gb776d


