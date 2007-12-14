From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] [NET]: Use {hton{s,l},cpu_to_be{16,32}}() where
 appropriate.
Date: Fri, 14 Dec 2007 16:28:35 +0900 (JST)
Message-ID: <20071214.162835.105268271.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43586 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716AbXLNH2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 02:28:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Please consider pulling the following changes from the branch
	net-2.6-dev-20071214
available at
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
which is on top of your net-2.6-devel tree.

Regards,

---
HEADLINES
---------

    [BRIDGE]: Use cpu_to_be16() where appropriate.
    [DECNET]: Use htons() where appropriate.
    [IEEE80211]: Use htons() where appropriate.
    [IPVS]: Use htons() where appropriate.
    [IRDA]: Use htons() where appropriate.
    [MAC80211]: Use htons() where appropriate.
    [RXRPC]: Use cpu_to_be32() where appropriate.
    [SUNRPC]: Use htonl() where appropriate.

DIFFSTAT
--------

 net/bridge/br_input.c           |    2 +-
 net/decnet/af_decnet.c          |    2 +-
 net/decnet/dn_nsp_out.c         |    2 +-
 net/decnet/dn_route.c           |    2 +-
 net/ieee80211/ieee80211_rx.c    |    4 ++--
 net/ipv4/ipvs/ip_vs_proto.c     |    2 +-
 net/ipv4/ipvs/ip_vs_proto_esp.c |   16 ++++++++--------
 net/irda/iriap.c                |    2 +-
 net/mac80211/rx.c               |    2 +-
 net/mac80211/wme.c              |    2 +-
 net/rxrpc/ar-connection.c       |    2 +-
 net/rxrpc/ar-input.c            |    4 ++--
 net/rxrpc/rxkad.c               |    4 ++--
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
 14 files changed, 26 insertions(+), 26 deletions(-)

CHANGESETS
----------

commit 8979a93df4ca6b9b411296265ad3591d9f780569
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:51:03 2007 +0900

    [BRIDGE]: Use cpu_to_be16() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 0ee79a7..255c00f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -109,7 +109,7 @@ static inline int is_link_local(const unsigned char *dest)
 {
 	__be16 *a = (__be16 *)dest;
 	static const __be16 *b = (const __be16 *)br_group_address;
-	static const __be16 m = __constant_cpu_to_be16(0xfff0);
+	static const __be16 m = cpu_to_be16(0xfff0);
 
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
 }

---
commit c60e701fabb6c2371a9fab2aa6a71b00bfa3cc1d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:51:49 2007 +0900

    [DECNET]: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 57d5749..acd48ee 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1904,7 +1904,7 @@ static inline struct sk_buff *dn_alloc_send_pskb(struct sock *sk,
 	struct sk_buff *skb = sock_alloc_send_skb(sk, datalen,
 						   noblock, errcode);
 	if (skb) {
-		skb->protocol = __constant_htons(ETH_P_DNA_RT);
+		skb->protocol = htons(ETH_P_DNA_RT);
 		skb->pkt_type = PACKET_OUTGOING;
 	}
 	return skb;
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 7404653..1964faf 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -124,7 +124,7 @@ struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri)
 	if ((skb = alloc_skb(size + hdr, pri)) == NULL)
 		return NULL;
 
-	skb->protocol = __constant_htons(ETH_P_DNA_RT);
+	skb->protocol = htons(ETH_P_DNA_RT);
 	skb->pkt_type = PACKET_OUTGOING;
 
 	if (sk)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2d95cf1..20263d9 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1551,7 +1551,7 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void
 			kfree_skb(skb);
 			return -ENODEV;
 		}
-		skb->protocol = __constant_htons(ETH_P_DNA_RT);
+		skb->protocol = htons(ETH_P_DNA_RT);
 		skb->dev = dev;
 		cb->src = fl.fld_src;
 		cb->dst = fl.fld_dst;

---
commit 6a29ce9b3427655b4e54e64d156199262dc08078
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:52:26 2007 +0900

    [IEEE80211]: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 21c0fad..13b12a6 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -45,7 +45,7 @@ static void ieee80211_monitor_rx(struct ieee80211_device *ieee,
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ieee80211_get_hdrlen(fc));
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_80211_RAW);
+	skb->protocol = htons(ETH_P_80211_RAW);
 	memset(skb->cb, 0, sizeof(skb->cb));
 	netif_rx(skb);
 }
@@ -800,7 +800,7 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 	if (skb2 != NULL) {
 		/* send to wireless media */
 		skb2->dev = dev;
-		skb2->protocol = __constant_htons(ETH_P_802_3);
+		skb2->protocol = htons(ETH_P_802_3);
 		skb_reset_mac_header(skb2);
 		skb_reset_network_header(skb2);
 		/* skb2->network_header += ETH_HLEN; */

---
commit de4433f3e1cc68fc98b3dcd66318843aeb4d1f63
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:53:11 2007 +0900

    [IPVS]: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index c0e11ec..dde28a2 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -165,7 +165,7 @@ ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
 	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
 	if (ih == NULL)
 		sprintf(buf, "%s TRUNCATED", pp->name);
-	else if (ih->frag_off & __constant_htons(IP_OFFSET))
+	else if (ih->frag_off & htons(IP_OFFSET))
 		sprintf(buf, "%s %u.%u.%u.%u->%u.%u.%u.%u frag",
 			pp->name, NIPQUAD(ih->saddr),
 			NIPQUAD(ih->daddr));
diff --git a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
index c36ccf0..aef0d3e 100644
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_esp.c
@@ -52,15 +52,15 @@ esp_conn_in_get(const struct sk_buff *skb,
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
 				       iph->saddr,
-				       __constant_htons(PORT_ISAKMP),
+				       htons(PORT_ISAKMP),
 				       iph->daddr,
-				       __constant_htons(PORT_ISAKMP));
+				       htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_in_get(IPPROTO_UDP,
 				       iph->daddr,
-				       __constant_htons(PORT_ISAKMP),
+				       htons(PORT_ISAKMP),
 				       iph->saddr,
-				       __constant_htons(PORT_ISAKMP));
+				       htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {
@@ -89,15 +89,15 @@ esp_conn_out_get(const struct sk_buff *skb, struct ip_vs_protocol *pp,
 	if (likely(!inverse)) {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
 					iph->saddr,
-					__constant_htons(PORT_ISAKMP),
+					htons(PORT_ISAKMP),
 					iph->daddr,
-					__constant_htons(PORT_ISAKMP));
+					htons(PORT_ISAKMP));
 	} else {
 		cp = ip_vs_conn_out_get(IPPROTO_UDP,
 					iph->daddr,
-					__constant_htons(PORT_ISAKMP),
+					htons(PORT_ISAKMP),
 					iph->saddr,
-					__constant_htons(PORT_ISAKMP));
+					htons(PORT_ISAKMP));
 	}
 
 	if (!cp) {

---
commit 3c334ad2235143509705b30dd05dd41582498c8d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:53:26 2007 +0900

    [IRDA]: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index a86a5d8..390a790 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -579,7 +579,7 @@ static void iriap_getvaluebyclass_response(struct iriap_cb *self,
 	fp[n++] = ret_code;
 
 	/* Insert list length (MSB first) */
-	tmp_be16 = __constant_htons(0x0001);
+	tmp_be16 = htons(0x0001);
 	memcpy(fp+n, &tmp_be16, 2);  n += 2;
 
 	/* Insert object identifier ( MSB first) */

---
commit bd45119bb0a0454ca7275b308465412e904b7487
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:54:23 2007 +0900

    [MAC80211]: Use htons() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 50f99e7..c6a6177 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1193,7 +1193,7 @@ ieee80211_deliver_skb(struct ieee80211_txrx_data *rx)
 
 	if (xmit_skb) {
 		/* send to wireless media */
-		xmit_skb->protocol = __constant_htons(ETH_P_802_3);
+		xmit_skb->protocol = htons(ETH_P_802_3);
 		skb_set_network_header(xmit_skb, 0);
 		skb_set_mac_header(xmit_skb, 0);
 		dev_queue_xmit(xmit_skb);
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 8dbdede..455fadc 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -55,7 +55,7 @@ static inline unsigned classify_1d(struct sk_buff *skb, struct Qdisc *qd)
 
 	/* check there is a valid IP header present */
 	offset = ieee80211_get_hdrlen_from_skb(skb) + 8 /* LLC + proto */;
-	if (skb->protocol != __constant_htons(ETH_P_IP) ||
+	if (skb->protocol != htons(ETH_P_IP) ||
 	    skb->len < offset + sizeof(*ip))
 		return 0;
 

---
commit df4caf512b5002deef7674595fea8612f55872da
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:55:22 2007 +0900

    [RXRPC]: Use cpu_to_be32() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index d6667f7..3869a58 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -651,7 +651,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 
 	candidate->trans = trans;
 	candidate->epoch = hdr->epoch;
-	candidate->cid = hdr->cid & __constant_cpu_to_be32(RXRPC_CIDMASK);
+	candidate->cid = hdr->cid & cpu_to_be32(RXRPC_CIDMASK);
 	candidate->service_id = hdr->serviceId;
 	candidate->security_ix = hdr->securityIndex;
 	candidate->in_clientflag = RXRPC_CLIENT_INITIATED;
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index f446d9b..f8a699e 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -595,7 +595,7 @@ dead_call:
 	read_unlock_bh(&conn->lock);
 
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
-	    sp->hdr.seq == __constant_cpu_to_be32(1)) {
+	    sp->hdr.seq == cpu_to_be32(1)) {
 		_debug("incoming call");
 		skb_queue_tail(&conn->trans->local->accept_queue, skb);
 		rxrpc_queue_work(&conn->trans->local->acceptor);
@@ -774,7 +774,7 @@ cant_route_call:
 	_debug("can't route call");
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
 	    sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
-		if (sp->hdr.seq == __constant_cpu_to_be32(1)) {
+		if (sp->hdr.seq == cpu_to_be32(1)) {
 			_debug("first packet");
 			skb_queue_tail(&local->accept_queue, skb);
 			rxrpc_queue_work(&local->acceptor);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 8e69d69..f48434a 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -284,7 +284,7 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 
 	/* calculate the security checksum */
 	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
-	x |= sp->hdr.seq & __constant_cpu_to_be32(0x3fffffff);
+	x |= sp->hdr.seq & cpu_to_be32(0x3fffffff);
 	tmpbuf.x[0] = sp->hdr.callNumber;
 	tmpbuf.x[1] = x;
 
@@ -518,7 +518,7 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 
 	/* validate the security checksum */
 	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
-	x |= sp->hdr.seq & __constant_cpu_to_be32(0x3fffffff);
+	x |= sp->hdr.seq & cpu_to_be32(0x3fffffff);
 	tmpbuf.x[0] = call->call_id;
 	tmpbuf.x[1] = x;
 

---
commit 5ef72974a45017d7c5a7caab023c5e98a24ad32a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Dec 12 03:55:42 2007 +0900

    [SUNRPC]: Use htonl() where appropriate.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9e11ce7..2738248 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -387,7 +387,7 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	headerp->rm_xid = rqst->rq_xid;
 	headerp->rm_vers = xdr_one;
 	headerp->rm_credit = htonl(r_xprt->rx_buf.rb_max_requests);
-	headerp->rm_type = __constant_htonl(RDMA_MSG);
+	headerp->rm_type = htonl(RDMA_MSG);
 
 	/*
 	 * Chunks needed for results?
@@ -465,11 +465,11 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 						RPCRDMA_INLINE_PAD_VALUE(rqst));
 
 		if (padlen) {
-			headerp->rm_type = __constant_htonl(RDMA_MSGP);
+			headerp->rm_type = htonl(RDMA_MSGP);
 			headerp->rm_body.rm_padded.rm_align =
 				htonl(RPCRDMA_INLINE_PAD_VALUE(rqst));
 			headerp->rm_body.rm_padded.rm_thresh =
-				__constant_htonl(RPCRDMA_INLINE_PAD_THRESH);
+				htonl(RPCRDMA_INLINE_PAD_THRESH);
 			headerp->rm_body.rm_padded.rm_pempty[0] = xdr_zero;
 			headerp->rm_body.rm_padded.rm_pempty[1] = xdr_zero;
 			headerp->rm_body.rm_padded.rm_pempty[2] = xdr_zero;

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
