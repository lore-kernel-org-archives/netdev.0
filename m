From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/3] net: replace uses of __constant_{endian}
Date: Wed, 28 Jan 2009 00:00:41 -0800
Message-ID: <1233129641.6717.46.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:44115 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbZA1IAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 03:00:46 -0500
Received: by rv-out-0506.google.com with SMTP id k40so6836237rvb.1
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 00:00:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Base versions handle constant folding now.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/arcnet/arc-rawmode.c        |    2 +-
 drivers/net/arcnet/capmode.c            |    4 ++--
 drivers/net/bonding/bond_3ad.h          |    2 +-
 drivers/net/bonding/bond_alb.c          |    4 ++--
 drivers/net/e1000/e1000_main.c          |    4 ++--
 drivers/net/e1000e/netdev.c             |    4 ++--
 drivers/net/enic/enic_main.c            |    4 ++--
 drivers/net/hamachi.c                   |    8 ++++----
 drivers/net/hamradio/bpqether.c         |    2 +-
 drivers/net/igb/igb_main.c              |    4 ++--
 drivers/net/ixgbe/ixgbe_main.c          |    4 ++--
 drivers/net/myri_sbus.c                 |    2 +-
 drivers/net/netxen/netxen_nic_main.c    |    8 ++++----
 drivers/net/niu.c                       |    4 ++--
 drivers/net/pppoe.c                     |    8 ++++----
 drivers/net/ps3_gelic_net.c             |    2 +-
 drivers/net/sfc/bitfield.h              |    4 ++--
 drivers/net/tun.c                       |    2 +-
 drivers/net/usb/hso.c                   |    3 +--
 drivers/net/via-velocity.h              |    6 +++---
 drivers/net/wan/hdlc.c                  |    2 +-
 drivers/net/wan/hdlc_cisco.c            |   16 ++++++++--------
 drivers/net/wan/hdlc_fr.c               |   16 ++++++++--------
 drivers/net/wan/hdlc_ppp.c              |    4 ++--
 drivers/net/wan/hdlc_raw.c              |    2 +-
 drivers/net/wan/lapbether.c             |    2 +-
 net/802/psnap.c                         |    2 +-
 net/8021q/vlan.c                        |    2 +-
 net/appletalk/ddp.c                     |    4 ++--
 net/ax25/af_ax25.c                      |    2 +-
 net/bridge/br_netfilter.c               |    2 +-
 net/can/af_can.c                        |    2 +-
 net/decnet/af_decnet.c                  |    2 +-
 net/decnet/dn_route.c                   |    2 +-
 net/dsa/mv88e6123_61_65.c               |    2 +-
 net/dsa/mv88e6131.c                     |    2 +-
 net/dsa/tag_dsa.c                       |    2 +-
 net/dsa/tag_edsa.c                      |    2 +-
 net/dsa/tag_trailer.c                   |    2 +-
 net/econet/af_econet.c                  |    2 +-
 net/ipv4/af_inet.c                      |    2 +-
 net/ipv4/arp.c                          |    2 +-
 net/ipv4/ipconfig.c                     |    8 ++++----
 net/ipv4/netfilter/nf_nat_snmp_basic.c  |    4 ++--
 net/ipv4/route.c                        |    4 ++--
 net/ipv4/xfrm4_policy.c                 |    2 +-
 net/ipv6/af_inet6.c                     |    2 +-
 net/ipv6/route.c                        |    4 ++--
 net/ipv6/xfrm6_policy.c                 |    2 +-
 net/ipx/af_ipx.c                        |    4 ++--
 net/irda/irmod.c                        |    2 +-
 net/llc/llc_core.c                      |    4 ++--
 net/netfilter/ipvs/ip_vs_sync.c         |    4 ++--
 net/netfilter/nf_conntrack_amanda.c     |    4 ++--
 net/netfilter/nf_conntrack_h323_main.c  |    8 ++++----
 net/netfilter/nf_conntrack_netbios_ns.c |    2 +-
 net/netfilter/nf_conntrack_pptp.c       |    2 +-
 net/phonet/af_phonet.c                  |    2 +-
 net/sctp/output.c                       |    2 +-
 net/sctp/sm_make_chunk.c                |    4 ++--
 net/x25/af_x25.c                        |    2 +-
 61 files changed, 111 insertions(+), 112 deletions(-)

diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index da017cb..646dfc5 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -122,7 +122,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
 
-	skb->protocol = __constant_htons(ETH_P_ARCNET);
+	skb->protocol = cpu_to_be16(ETH_P_ARCNET);
 ;
 	netif_rx(skb);
 }
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 1613929..083e210 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -148,7 +148,7 @@ static void rx(struct net_device *dev, int bufnum,
 
 	BUGLVL(D_SKB) arcnet_dump_skb(dev, skb, "rx");
 
-	skb->protocol = __constant_htons(ETH_P_ARCNET);
+	skb->protocol = cpu_to_be16(ETH_P_ARCNET);
 ;
 	netif_rx(skb);
 }
@@ -282,7 +282,7 @@ static int ack_tx(struct net_device *dev, int acked)
   BUGMSG(D_PROTO, "Ackknowledge for cap packet %x.\n",
 	 *((int*)&ackpkt->soft.cap.cookie[0]));
 
-  ackskb->protocol = __constant_htons(ETH_P_ARCNET);
+  ackskb->protocol = cpu_to_be16(ETH_P_ARCNET);
 
   BUGLVL(D_SKB) arcnet_dump_skb(dev, ackskb, "ack_tx_recv");
   netif_rx(ackskb);
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 8a83eb2..a306230 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -29,7 +29,7 @@
 
 // General definitions
 #define BOND_ETH_P_LACPDU       0x8809
-#define PKT_TYPE_LACPDU         __constant_htons(BOND_ETH_P_LACPDU)
+#define PKT_TYPE_LACPDU         cpu_to_be16(BOND_ETH_P_LACPDU)
 #define AD_TIMER_INTERVAL       100 /*msec*/
 
 #define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 27fb7f5..409b140 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -822,7 +822,7 @@ static int rlb_initialize(struct bonding *bond)
 	_unlock_rx_hashtbl(bond);
 
 	/*initialize packet type*/
-	pk_type->type = __constant_htons(ETH_P_ARP);
+	pk_type->type = cpu_to_be16(ETH_P_ARP);
 	pk_type->dev = NULL;
 	pk_type->func = rlb_arp_recv;
 
@@ -892,7 +892,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 	memset(&pkt, 0, size);
 	memcpy(pkt.mac_dst, mac_addr, ETH_ALEN);
 	memcpy(pkt.mac_src, mac_addr, ETH_ALEN);
-	pkt.type = __constant_htons(ETH_P_LOOP);
+	pkt.type = cpu_to_be16(ETH_P_LOOP);
 
 	for (i = 0; i < MAX_LP_BURST; i++) {
 		struct sk_buff *skb;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7ec1a0c..b395f87 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2860,11 +2860,11 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter,
 		return false;
 
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
 		break;
-	case __constant_htons(ETH_P_IPV6):
+	case cpu_to_be16(ETH_P_IPV6):
 		/* XXX not handling all IPV6 headers */
 		if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e04b392..c425b19 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3770,11 +3770,11 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 		return 0;
 
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
 		break;
-	case __constant_htons(ETH_P_IPV6):
+	case cpu_to_be16(ETH_P_IPV6):
 		/* XXX not handling all IPV6 headers */
 		if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 4617956..5dd1156 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -570,11 +570,11 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 	 * to each TCP segment resulting from the TSO.
 	 */
 
-	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+	if (skb->protocol == cpu_to_be16(ETH_P_IP)) {
 		ip_hdr(skb)->check = 0;
 		tcp_hdr(skb)->check = ~csum_tcpudp_magic(ip_hdr(skb)->saddr,
 			ip_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);
-	} else if (skb->protocol == __constant_htons(ETH_P_IPV6)) {
+	} else if (skb->protocol == cpu_to_be16(ETH_P_IPV6)) {
 		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
 			&ipv6_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);
 	}
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 7e8b3c5..455641f 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1244,7 +1244,7 @@ do { \
     csum_add(sum, (ih)->saddr & 0xffff); \
     csum_add(sum, (ih)->daddr >> 16); \
     csum_add(sum, (ih)->daddr & 0xffff); \
-    csum_add(sum, __constant_htons(IPPROTO_UDP)); \
+    csum_add(sum, cpu_to_be16(IPPROTO_UDP)); \
     csum_add(sum, (uh)->len); \
 } while (0)
 
@@ -1255,7 +1255,7 @@ do { \
     csum_add(sum, (ih)->saddr & 0xffff); \
     csum_add(sum, (ih)->daddr >> 16); \
     csum_add(sum, (ih)->daddr & 0xffff); \
-    csum_add(sum, __constant_htons(IPPROTO_TCP)); \
+    csum_add(sum, cpu_to_be16(IPPROTO_TCP)); \
     csum_add(sum, htons(len)); \
 } while (0)
 #endif
@@ -1296,7 +1296,7 @@ static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    /* tack on checksum tag */
 	    u32 tagval = 0;
 	    struct ethhdr *eh = (struct ethhdr *)skb->data;
-	    if (eh->h_proto == __constant_htons(ETH_P_IP)) {
+	    if (eh->h_proto == cpu_to_be16(ETH_P_IP)) {
 		struct iphdr *ih = (struct iphdr *)((char *)eh + ETH_HLEN);
 		if (ih->protocol == IPPROTO_UDP) {
 		    struct udphdr *uh
@@ -1605,7 +1605,7 @@ static int hamachi_rx(struct net_device *dev)
 				 */
 				if (ntohs(ih->tot_len) >= 46){
 					/* don't worry about frags */
-					if (!(ih->frag_off & __constant_htons(IP_MF|IP_OFFSET))) {
+					if (!(ih->frag_off & cpu_to_be16(IP_MF|IP_OFFSET))) {
 						u32 inv = *(u32 *) &buf_addr[data_size - 16];
 						u32 *p = (u32 *) &buf_addr[data_size - 20];
 						register u32 crc, p_r, p_r1;
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 1f65d1e..2c619bc 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -97,7 +97,7 @@ static int bpq_rcv(struct sk_buff *, struct net_device *, struct packet_type *,
 static int bpq_device_event(struct notifier_block *, unsigned long, void *);
 
 static struct packet_type bpq_packet_type = {
-	.type	= __constant_htons(ETH_P_BPQ),
+	.type	= cpu_to_be16(ETH_P_BPQ),
 	.func	= bpq_rcv,
 };
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e11043d..f6be610 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2749,12 +2749,12 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			switch (skb->protocol) {
-			case __constant_htons(ETH_P_IP):
+			case cpu_to_be16(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
 				break;
-			case __constant_htons(ETH_P_IPV6):
+			case cpu_to_be16(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 43980dc..467b6d3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3566,13 +3566,13 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			switch (skb->protocol) {
-			case __constant_htons(ETH_P_IP):
+			case cpu_to_be16(ETH_P_IP):
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					type_tucmd_mlhl |=
 					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
 				break;
-			case __constant_htons(ETH_P_IPV6):
+			case cpu_to_be16(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					type_tucmd_mlhl |=
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 899ed06..88b5288 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -748,7 +748,7 @@ static int myri_rebuild_header(struct sk_buff *skb)
 	switch (eth->h_proto)
 	{
 #ifdef CONFIG_INET
-	case __constant_htons(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IP):
  		return arp_find(eth->h_dest, skb);
 #endif
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index cc06cc5..ada462e 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1170,7 +1170,7 @@ static bool netxen_tso_check(struct net_device *netdev,
 	__be16 protocol = skb->protocol;
 	u16 flags = 0;
 
-	if (protocol == __constant_htons(ETH_P_8021Q)) {
+	if (protocol == cpu_to_be16(ETH_P_8021Q)) {
 		struct vlan_ethhdr *vh = (struct vlan_ethhdr *)skb->data;
 		protocol = vh->h_vlan_encapsulated_proto;
 		flags = FLAGS_VLAN_TAGGED;
@@ -1183,21 +1183,21 @@ static bool netxen_tso_check(struct net_device *netdev,
 		desc->total_hdr_length =
 			skb_transport_offset(skb) + tcp_hdrlen(skb);
 
-		opcode = (protocol == __constant_htons(ETH_P_IPV6)) ?
+		opcode = (protocol == cpu_to_be16(ETH_P_IPV6)) ?
 				TX_TCP_LSO6 : TX_TCP_LSO;
 		tso = true;
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4proto;
 
-		if (protocol == __constant_htons(ETH_P_IP)) {
+		if (protocol == cpu_to_be16(ETH_P_IP)) {
 			l4proto = ip_hdr(skb)->protocol;
 
 			if (l4proto == IPPROTO_TCP)
 				opcode = TX_TCP_PKT;
 			else if(l4proto == IPPROTO_UDP)
 				opcode = TX_UDP_PKT;
-		} else if (protocol == __constant_htons(ETH_P_IPV6)) {
+		} else if (protocol == cpu_to_be16(ETH_P_IPV6)) {
 			l4proto = ipv6_hdr(skb)->nexthdr;
 
 			if (l4proto == IPPROTO_TCP)
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 4a5a089..1cf9011 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6446,11 +6446,11 @@ static u64 niu_compute_tx_flags(struct sk_buff *skb, struct ethhdr *ehdr,
 
 	ipv6 = ihl = 0;
 	switch (skb->protocol) {
-	case __constant_htons(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IP):
 		ip_proto = ip_hdr(skb)->protocol;
 		ihl = ip_hdr(skb)->ihl;
 		break;
-	case __constant_htons(ETH_P_IPV6):
+	case cpu_to_be16(ETH_P_IPV6):
 		ip_proto = ipv6_hdr(skb)->nexthdr;
 		ihl = (40 >> 2);
 		ipv6 = 1;
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 074803a..1011fd6 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -514,12 +514,12 @@ out:
 }
 
 static struct packet_type pppoes_ptype = {
-	.type	= __constant_htons(ETH_P_PPP_SES),
+	.type	= cpu_to_be16(ETH_P_PPP_SES),
 	.func	= pppoe_rcv,
 };
 
 static struct packet_type pppoed_ptype = {
-	.type	= __constant_htons(ETH_P_PPP_DISC),
+	.type	= cpu_to_be16(ETH_P_PPP_DISC),
 	.func	= pppoe_disc_rcv,
 };
 
@@ -877,7 +877,7 @@ static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
 	skb->dev = dev;
 
 	skb->priority = sk->sk_priority;
-	skb->protocol = __constant_htons(ETH_P_PPP_SES);
+	skb->protocol = cpu_to_be16(ETH_P_PPP_SES);
 
 	ph = (struct pppoe_hdr *)skb_put(skb, total_len + sizeof(struct pppoe_hdr));
 	start = (char *)&ph->tag[0];
@@ -937,7 +937,7 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
 	ph->sid	= po->num;
 	ph->length = htons(data_len);
 
-	skb->protocol = __constant_htons(ETH_P_PPP_SES);
+	skb->protocol = cpu_to_be16(ETH_P_PPP_SES);
 	skb->dev = dev;
 
 	dev_hard_header(skb, dev, ETH_P_PPP_SES,
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 06649d0..30900b3 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -745,7 +745,7 @@ static inline struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
 	/* Move the mac addresses to the top of buffer */
 	memmove(skb->data, skb->data + VLAN_HLEN, 2 * ETH_ALEN);
 
-	veth->h_vlan_proto = __constant_htons(ETH_P_8021Q);
+	veth->h_vlan_proto = cpu_to_be16(ETH_P_8021Q);
 	veth->h_vlan_TCI = htons(tag);
 
 	return skb;
diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
index d95c218..d54d84c 100644
--- a/drivers/net/sfc/bitfield.h
+++ b/drivers/net/sfc/bitfield.h
@@ -543,7 +543,7 @@ typedef union efx_oword {
 
 /* Static initialiser */
 #define EFX_OWORD32(a, b, c, d)						\
-	{ .u32 = { __constant_cpu_to_le32(a), __constant_cpu_to_le32(b), \
-		   __constant_cpu_to_le32(c), __constant_cpu_to_le32(d) } }
+	{ .u32 = { cpu_to_le32(a), cpu_to_le32(b), \
+		   cpu_to_le32(c), cpu_to_le32(d) } }
 
 #endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e9bcbdf..457f2d7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -543,7 +543,7 @@ static struct sk_buff *tun_alloc_skb(size_t prepad, size_t len, size_t linear,
 /* Get packet from user space buffer */
 static __inline__ ssize_t tun_get_user(struct tun_struct *tun, struct iovec *iv, size_t count)
 {
-	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
+	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
 	size_t len = count, align = 0;
 	struct virtio_net_hdr gso = { 0 };
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 0d0fa91..806cc5d 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -934,8 +934,7 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 			if (!odev->rx_buf_missing) {
 				/* Packet is complete. Inject into stack. */
 				/* We have IP packet here */
-				odev->skb_rx_buf->protocol =
-						__constant_htons(ETH_P_IP);
+				odev->skb_rx_buf->protocol = cpu_to_be16(ETH_P_IP);
 				/* don't check it */
 				odev->skb_rx_buf->ip_summed =
 					CHECKSUM_UNNECESSARY;
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 29a3309..ea43e18 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -183,7 +183,7 @@ struct rdesc1 {
 };
 
 enum {
-	RX_INTEN = __constant_cpu_to_le16(0x8000)
+	RX_INTEN = cpu_to_le16(0x8000)
 };
 
 struct rx_desc {
@@ -210,7 +210,7 @@ struct tdesc1 {
 } __attribute__ ((__packed__));
 
 enum {
-	TD_QUEUE = __constant_cpu_to_le16(0x8000)
+	TD_QUEUE = cpu_to_le16(0x8000)
 };
 
 struct td_buf {
@@ -242,7 +242,7 @@ struct velocity_td_info {
 
 enum  velocity_owner {
 	OWNED_BY_HOST = 0,
-	OWNED_BY_NIC = __constant_cpu_to_le16(0x8000)
+	OWNED_BY_NIC = cpu_to_le16(0x8000)
 };
 

diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 43da8bd..5ce4372 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -349,7 +349,7 @@ EXPORT_SYMBOL(attach_hdlc_protocol);
 EXPORT_SYMBOL(detach_hdlc_protocol);
 
 static struct packet_type hdlc_packet_type = {
-	.type = __constant_htons(ETH_P_HDLC),
+	.type = cpu_to_be16(ETH_P_HDLC),
 	.func = hdlc_rcv,
 };
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index af3fd4f..cf5fd17 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -117,7 +117,7 @@ static void cisco_keepalive_send(struct net_device *dev, u32 type,
 	data->type = htonl(type);
 	data->par1 = par1;
 	data->par2 = par2;
-	data->rel = __constant_htons(0xFFFF);
+	data->rel = cpu_to_be16(0xFFFF);
 	/* we will need do_div here if 1000 % HZ != 0 */
 	data->time = htonl((jiffies - INITIAL_JIFFIES) * (1000 / HZ));
 
@@ -136,20 +136,20 @@ static __be16 cisco_type_trans(struct sk_buff *skb, struct net_device *dev)
 	struct hdlc_header *data = (struct hdlc_header*)skb->data;
 
 	if (skb->len < sizeof(struct hdlc_header))
-		return __constant_htons(ETH_P_HDLC);
+		return cpu_to_be16(ETH_P_HDLC);
 
 	if (data->address != CISCO_MULTICAST &&
 	    data->address != CISCO_UNICAST)
-		return __constant_htons(ETH_P_HDLC);
+		return cpu_to_be16(ETH_P_HDLC);
 
 	switch(data->protocol) {
-	case __constant_htons(ETH_P_IP):
-	case __constant_htons(ETH_P_IPX):
-	case __constant_htons(ETH_P_IPV6):
+	case cpu_to_be16(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IPX):
+	case cpu_to_be16(ETH_P_IPV6):
 		skb_pull(skb, sizeof(struct hdlc_header));
 		return data->protocol;
 	default:
-		return __constant_htons(ETH_P_HDLC);
+		return cpu_to_be16(ETH_P_HDLC);
 	}
 }
 
@@ -194,7 +194,7 @@ static int cisco_rx(struct sk_buff *skb)
 		case CISCO_ADDR_REQ: /* Stolen from syncppp.c :-) */
 			in_dev = dev->ip_ptr;
 			addr = 0;
-			mask = __constant_htonl(~0); /* is the mask correct? */
+			mask = ~cpu_to_be32(0); /* is the mask correct? */
 
 			if (in_dev != NULL) {
 				struct in_ifaddr **ifap = &in_dev->ifa_list;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 70e57ce..8005301 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -278,31 +278,31 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 	struct sk_buff *skb = *skb_p;
 
 	switch (skb->protocol) {
-	case __constant_htons(NLPID_CCITT_ANSI_LMI):
+	case cpu_to_be16(NLPID_CCITT_ANSI_LMI):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_CCITT_ANSI_LMI;
 		break;
 
-	case __constant_htons(NLPID_CISCO_LMI):
+	case cpu_to_be16(NLPID_CISCO_LMI):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_CISCO_LMI;
 		break;
 
-	case __constant_htons(ETH_P_IP):
+	case cpu_to_be16(ETH_P_IP):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_IP;
 		break;
 
-	case __constant_htons(ETH_P_IPV6):
+	case cpu_to_be16(ETH_P_IPV6):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_IPV6;
 		break;
 
-	case __constant_htons(ETH_P_802_3):
+	case cpu_to_be16(ETH_P_802_3):
 		head_len = 10;
 		if (skb_headroom(skb) < head_len) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb,
@@ -426,7 +426,7 @@ static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 				skb_put(skb, pad);
 				memset(skb->data + len, 0, pad);
 			}
-			skb->protocol = __constant_htons(ETH_P_802_3);
+			skb->protocol = cpu_to_be16(ETH_P_802_3);
 		}
 		if (!fr_hard_header(&skb, pvc->dlci)) {
 			dev->stats.tx_bytes += skb->len;
@@ -496,10 +496,10 @@ static void fr_lmi_send(struct net_device *dev, int fullrep)
 	memset(skb->data, 0, len);
 	skb_reserve(skb, 4);
 	if (lmi == LMI_CISCO) {
-		skb->protocol = __constant_htons(NLPID_CISCO_LMI);
+		skb->protocol = cpu_to_be16(NLPID_CISCO_LMI);
 		fr_hard_header(&skb, LMI_CISCO_DLCI);
 	} else {
-		skb->protocol = __constant_htons(NLPID_CCITT_ANSI_LMI);
+		skb->protocol = cpu_to_be16(NLPID_CCITT_ANSI_LMI);
 		fr_hard_header(&skb, LMI_CCITT_ANSI_DLCI);
 	}
 	data = skb_tail_pointer(skb);
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 7b8a5ea..72a7cda 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -150,11 +150,11 @@ static __be16 ppp_type_trans(struct sk_buff *skb, struct net_device *dev)
 		return htons(ETH_P_HDLC);
 
 	switch (data->protocol) {
-	case __constant_htons(PID_IP):
+	case cpu_to_be16(PID_IP):
 		skb_pull(skb, sizeof(struct hdlc_header));
 		return htons(ETH_P_IP);
 
-	case __constant_htons(PID_IPV6):
+	case cpu_to_be16(PID_IPV6):
 		skb_pull(skb, sizeof(struct hdlc_header));
 		return htons(ETH_P_IPV6);
 
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index 6e92c64..19f51fd 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -27,7 +27,7 @@ static int raw_ioctl(struct net_device *dev, struct ifreq *ifr);
 
 static __be16 raw_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	return __constant_htons(ETH_P_IP);
+	return cpu_to_be16(ETH_P_IP);
 }
 
 static struct hdlc_proto proto = {
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 5b61b3e..da9dcf5 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -422,7 +422,7 @@ static int lapbeth_device_event(struct notifier_block *this,
 /* ------------------------------------------------------------------------ */
 
 static struct packet_type lapbeth_packet_type = {
-	.type = __constant_htons(ETH_P_DEC),
+	.type = cpu_to_be16(ETH_P_DEC),
 	.func = lapbeth_rcv,
 };
 
diff --git a/net/802/psnap.c b/net/802/psnap.c
index 70980ba..6ed7117 100644
--- a/net/802/psnap.c
+++ b/net/802/psnap.c
@@ -51,7 +51,7 @@ static int snap_rcv(struct sk_buff *skb, struct net_device *dev,
 	int rc = 1;
 	struct datalink_proto *proto;
 	static struct packet_type snap_packet_type = {
-		.type = __constant_htons(ETH_P_SNAP),
+		.type = cpu_to_be16(ETH_P_SNAP),
 	};
 
 	if (unlikely(!pskb_may_pull(skb, 5)))
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 41e8f65..4163ea6 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -52,7 +52,7 @@ static const char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
 static const char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
 static struct packet_type vlan_packet_type = {
-	.type = __constant_htons(ETH_P_8021Q),
+	.type = cpu_to_be16(ETH_P_8021Q),
 	.func = vlan_skb_recv, /* VLAN receive method */
 };
 
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 5abce07..510a678 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1861,12 +1861,12 @@ static struct notifier_block ddp_notifier = {
 };
 
 static struct packet_type ltalk_packet_type = {
-	.type		= __constant_htons(ETH_P_LOCALTALK),
+	.type		= cpu_to_be16(ETH_P_LOCALTALK),
 	.func		= ltalk_rcv,
 };
 
 static struct packet_type ppptalk_packet_type = {
-	.type		= __constant_htons(ETH_P_PPPTALK),
+	.type		= cpu_to_be16(ETH_P_PPPTALK),
 	.func		= atalk_rcv,
 };
 
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 00d9e5e..d127fd3 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1986,7 +1986,7 @@ static const struct proto_ops ax25_proto_ops = {
  *	Called by socket.c on kernel start up
  */
 static struct packet_type ax25_packet_type = {
-	.type	=	__constant_htons(ETH_P_AX25),
+	.type	=	cpu_to_be16(ETH_P_AX25),
 	.dev	=	NULL,				/* All devices */
 	.func	=	ax25_kiss_rcv,
 };
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index cf754ac..3953ac4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -107,7 +107,7 @@ static void fake_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 static struct dst_ops fake_dst_ops = {
 	.family =		AF_INET,
-	.protocol =		__constant_htons(ETH_P_IP),
+	.protocol =		cpu_to_be16(ETH_P_IP),
 	.update_pmtu =		fake_update_pmtu,
 	.entries =		ATOMIC_INIT(0),
 };
diff --git a/net/can/af_can.c b/net/can/af_can.c
index fa417ca..d90e8dd 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -828,7 +828,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
  */
 
 static struct packet_type can_packet __read_mostly = {
-	.type = __constant_htons(ETH_P_CAN),
+	.type = cpu_to_be16(ETH_P_CAN),
 	.dev  = NULL,
 	.func = can_rcv,
 };
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index cf0e184..12bf7d4 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2113,7 +2113,7 @@ static struct notifier_block dn_dev_notifier = {
 extern int dn_route_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
 
 static struct packet_type dn_dix_packet_type = {
-	.type =		__constant_htons(ETH_P_DNA_RT),
+	.type =		cpu_to_be16(ETH_P_DNA_RT),
 	.dev =		NULL,		/* All devices */
 	.func =		dn_route_rcv,
 };
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index c754670..5130dee 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -124,7 +124,7 @@ int decnet_dst_gc_interval = 2;
 
 static struct dst_ops dn_dst_ops = {
 	.family =		PF_DECnet,
-	.protocol =		__constant_htons(ETH_P_DNA_RT),
+	.protocol =		cpu_to_be16(ETH_P_DNA_RT),
 	.gc_thresh =		128,
 	.gc =			dn_dst_gc,
 	.check =		dn_dst_check,
diff --git a/net/dsa/mv88e6123_61_65.c b/net/dsa/mv88e6123_61_65.c
index ec8c6a0..1003187 100644
--- a/net/dsa/mv88e6123_61_65.c
+++ b/net/dsa/mv88e6123_61_65.c
@@ -394,7 +394,7 @@ static int mv88e6123_61_65_get_sset_count(struct dsa_switch *ds)
 }
 
 static struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
-	.tag_protocol		= __constant_htons(ETH_P_EDSA),
+	.tag_protocol		= cpu_to_be16(ETH_P_EDSA),
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6123_61_65_probe,
 	.setup			= mv88e6123_61_65_setup,
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 374d46a..70fae24 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -353,7 +353,7 @@ static int mv88e6131_get_sset_count(struct dsa_switch *ds)
 }
 
 static struct dsa_switch_driver mv88e6131_switch_driver = {
-	.tag_protocol		= __constant_htons(ETH_P_DSA),
+	.tag_protocol		= cpu_to_be16(ETH_P_DSA),
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
 	.probe			= mv88e6131_probe,
 	.setup			= mv88e6131_setup,
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index f99a019..63e532a 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -176,7 +176,7 @@ out:
 }
 
 static struct packet_type dsa_packet_type = {
-	.type	= __constant_htons(ETH_P_DSA),
+	.type	= cpu_to_be16(ETH_P_DSA),
 	.func	= dsa_rcv,
 };
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 328ec95..6197f9a 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -195,7 +195,7 @@ out:
 }
 
 static struct packet_type edsa_packet_type = {
-	.type	= __constant_htons(ETH_P_EDSA),
+	.type	= cpu_to_be16(ETH_P_EDSA),
 	.func	= edsa_rcv,
 };
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index b591328..d7e7f42 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -112,7 +112,7 @@ out:
 }
 
 static struct packet_type trailer_packet_type = {
-	.type	= __constant_htons(ETH_P_TRAILER),
+	.type	= cpu_to_be16(ETH_P_TRAILER),
 	.func	= trailer_rcv,
 };
 
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 8789d2b..7bf3558 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1103,7 +1103,7 @@ drop:
 }
 
 static struct packet_type econet_packet_type = {
-	.type =		__constant_htons(ETH_P_ECONET),
+	.type =		cpu_to_be16(ETH_P_ECONET),
 	.func =		econet_rcv,
 };
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 743f554..d02142c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1501,7 +1501,7 @@ static int ipv4_proc_init(void);
  */
 
 static struct packet_type ip_packet_type = {
-	.type = __constant_htons(ETH_P_IP),
+	.type = cpu_to_be16(ETH_P_IP),
 	.func = ip_rcv,
 	.gso_send_check = inet_gso_send_check,
 	.gso_segment = inet_gso_segment,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 29a74c0..3f6b735 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1226,7 +1226,7 @@ void arp_ifdown(struct net_device *dev)
  */
 
 static struct packet_type arp_packet_type = {
-	.type =	__constant_htons(ETH_P_ARP),
+	.type =	cpu_to_be16(ETH_P_ARP),
 	.func =	arp_rcv,
 };
 
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 42a0f3d..5bbf0c2 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -100,8 +100,8 @@
 #define CONF_NAMESERVERS_MAX   3       /* Maximum number of nameservers
 					   - '3' from resolv.h */
 
-#define NONE __constant_htonl(INADDR_NONE)
-#define ANY __constant_htonl(INADDR_ANY)
+#define NONE cpu_to_be32(INADDR_NONE)
+#define ANY cpu_to_be32(INADDR_ANY)
 
 /*
  * Public IP configuration
@@ -406,7 +406,7 @@ static int __init ic_defaults(void)
 static int ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev);
 
 static struct packet_type rarp_packet_type __initdata = {
-	.type =	__constant_htons(ETH_P_RARP),
+	.type =	cpu_to_be16(ETH_P_RARP),
 	.func =	ic_rarp_recv,
 };
 
@@ -568,7 +568,7 @@ struct bootp_pkt {		/* BOOTP packet format */
 static int ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev);
 
 static struct packet_type bootp_packet_type __initdata = {
-	.type =	__constant_htons(ETH_P_IP),
+	.type =	cpu_to_be16(ETH_P_IP),
 	.func =	ic_bootp_recv,
 };
 
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 182f845..d9521f6 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1292,7 +1292,7 @@ static struct nf_conntrack_helper snmp_helper __read_mostly = {
 	.expect_policy		= &snmp_exp_policy,
 	.name			= "snmp",
 	.tuple.src.l3num	= AF_INET,
-	.tuple.src.u.udp.port	= __constant_htons(SNMP_PORT),
+	.tuple.src.u.udp.port	= cpu_to_be16(SNMP_PORT),
 	.tuple.dst.protonum	= IPPROTO_UDP,
 };
 
@@ -1302,7 +1302,7 @@ static struct nf_conntrack_helper snmp_trap_helper __read_mostly = {
 	.expect_policy		= &snmp_exp_policy,
 	.name			= "snmp_trap",
 	.tuple.src.l3num	= AF_INET,
-	.tuple.src.u.udp.port	= __constant_htons(SNMP_TRAP_PORT),
+	.tuple.src.u.udp.port	= cpu_to_be16(SNMP_TRAP_PORT),
 	.tuple.dst.protonum	= IPPROTO_UDP,
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6a9e204..5caee60 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -151,7 +151,7 @@ static void rt_emergency_hash_rebuild(struct net *net);
 
 static struct dst_ops ipv4_dst_ops = {
 	.family =		AF_INET,
-	.protocol =		__constant_htons(ETH_P_IP),
+	.protocol =		cpu_to_be16(ETH_P_IP),
 	.gc =			rt_garbage_collect,
 	.check =		ipv4_dst_check,
 	.destroy =		ipv4_dst_destroy,
@@ -2696,7 +2696,7 @@ static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 static struct dst_ops ipv4_dst_blackhole_ops = {
 	.family			=	AF_INET,
-	.protocol		=	__constant_htons(ETH_P_IP),
+	.protocol		=	cpu_to_be16(ETH_P_IP),
 	.destroy		=	ipv4_dst_destroy,
 	.check			=	ipv4_dst_check,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 2ad24ba..60d918c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -241,7 +241,7 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm4_dst_ops = {
 	.family =		AF_INET,
-	.protocol =		__constant_htons(ETH_P_IP),
+	.protocol =		cpu_to_be16(ETH_P_IP),
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
 	.destroy =		xfrm4_dst_destroy,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index c802bc1..e892103 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -880,7 +880,7 @@ out_unlock:
 }
 
 static struct packet_type ipv6_packet_type = {
-	.type = __constant_htons(ETH_P_IPV6),
+	.type = cpu_to_be16(ETH_P_IPV6),
 	.func = ipv6_rcv,
 	.gso_send_check = ipv6_gso_send_check,
 	.gso_segment = ipv6_gso_segment,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c4a5982..f41553d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -98,7 +98,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 
 static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
-	.protocol		=	__constant_htons(ETH_P_IPV6),
+	.protocol		=	cpu_to_be16(ETH_P_IPV6),
 	.gc			=	ip6_dst_gc,
 	.gc_thresh		=	1024,
 	.check			=	ip6_dst_check,
@@ -117,7 +117,7 @@ static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 
 static struct dst_ops ip6_dst_blackhole_ops = {
 	.family			=	AF_INET6,
-	.protocol		=	__constant_htons(ETH_P_IPV6),
+	.protocol		=	cpu_to_be16(ETH_P_IPV6),
 	.destroy		=	ip6_dst_destroy,
 	.check			=	ip6_dst_check,
 	.update_pmtu		=	ip6_rt_blackhole_update_pmtu,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 97ab068..b4b16a4 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -272,7 +272,7 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm6_dst_ops = {
 	.family =		AF_INET6,
-	.protocol =		__constant_htons(ETH_P_IPV6),
+	.protocol =		cpu_to_be16(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
 	.destroy =		xfrm6_dst_destroy,
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index b6e70f9..43d0ffc 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1959,12 +1959,12 @@ static const struct proto_ops SOCKOPS_WRAPPED(ipx_dgram_ops) = {
 SOCKOPS_WRAP(ipx_dgram, PF_IPX);
 
 static struct packet_type ipx_8023_packet_type = {
-	.type		= __constant_htons(ETH_P_802_3),
+	.type		= cpu_to_be16(ETH_P_802_3),
 	.func		= ipx_rcv,
 };
 
 static struct packet_type ipx_dix_packet_type = {
-	.type		= __constant_htons(ETH_P_IPX),
+	.type		= cpu_to_be16(ETH_P_IPX),
 	.func		= ipx_rcv,
 };
 
diff --git a/net/irda/irmod.c b/net/irda/irmod.c
index 4c487a8..1bb607f 100644
--- a/net/irda/irmod.c
+++ b/net/irda/irmod.c
@@ -56,7 +56,7 @@ EXPORT_SYMBOL(irda_debug);
  * Tell the kernel how IrDA packets should be handled.
  */
 static struct packet_type irda_packet_type = {
-	.type	= __constant_htons(ETH_P_IRDA),
+	.type	= cpu_to_be16(ETH_P_IRDA),
 	.func	= irlap_driver_rcv,	/* Packet type handler irlap_frame.c */
 };
 
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 50d5b10..a7fe1ad 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -148,12 +148,12 @@ void llc_sap_close(struct llc_sap *sap)
 }
 
 static struct packet_type llc_packet_type = {
-	.type = __constant_htons(ETH_P_802_2),
+	.type = cpu_to_be16(ETH_P_802_2),
 	.func = llc_rcv,
 };
 
 static struct packet_type llc_tr_packet_type = {
-	.type = __constant_htons(ETH_P_TR_802_2),
+	.type = cpu_to_be16(ETH_P_TR_802_2),
 	.func = llc_rcv,
 };
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 6be5d4e..5c48378 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -149,8 +149,8 @@ static struct task_struct *sync_backup_thread;
 /* multicast addr */
 static struct sockaddr_in mcast_addr = {
 	.sin_family		= AF_INET,
-	.sin_port		= __constant_htons(IP_VS_SYNC_PORT),
-	.sin_addr.s_addr	= __constant_htonl(IP_VS_SYNC_GROUP),
+	.sin_port		= cpu_to_be16(IP_VS_SYNC_PORT),
+	.sin_addr.s_addr	= cpu_to_be32(IP_VS_SYNC_GROUP),
 };
 

diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 4f8fcf4..07d9d88 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -177,7 +177,7 @@ static struct nf_conntrack_helper amanda_helper[2] __read_mostly = {
 		.me			= THIS_MODULE,
 		.help			= amanda_help,
 		.tuple.src.l3num	= AF_INET,
-		.tuple.src.u.udp.port	= __constant_htons(10080),
+		.tuple.src.u.udp.port	= cpu_to_be16(10080),
 		.tuple.dst.protonum	= IPPROTO_UDP,
 		.expect_policy		= &amanda_exp_policy,
 	},
@@ -186,7 +186,7 @@ static struct nf_conntrack_helper amanda_helper[2] __read_mostly = {
 		.me			= THIS_MODULE,
 		.help			= amanda_help,
 		.tuple.src.l3num	= AF_INET6,
-		.tuple.src.u.udp.port	= __constant_htons(10080),
+		.tuple.src.u.udp.port	= cpu_to_be16(10080),
 		.tuple.dst.protonum	= IPPROTO_UDP,
 		.expect_policy		= &amanda_exp_policy,
 	},
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 687bd63..6636949 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1167,7 +1167,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_q931[] __read_mostly = {
 		.name			= "Q.931",
 		.me			= THIS_MODULE,
 		.tuple.src.l3num	= AF_INET,
-		.tuple.src.u.tcp.port	= __constant_htons(Q931_PORT),
+		.tuple.src.u.tcp.port	= cpu_to_be16(Q931_PORT),
 		.tuple.dst.protonum	= IPPROTO_TCP,
 		.help			= q931_help,
 		.expect_policy		= &q931_exp_policy,
@@ -1176,7 +1176,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_q931[] __read_mostly = {
 		.name			= "Q.931",
 		.me			= THIS_MODULE,
 		.tuple.src.l3num	= AF_INET6,
-		.tuple.src.u.tcp.port	= __constant_htons(Q931_PORT),
+		.tuple.src.u.tcp.port	= cpu_to_be16(Q931_PORT),
 		.tuple.dst.protonum	= IPPROTO_TCP,
 		.help			= q931_help,
 		.expect_policy		= &q931_exp_policy,
@@ -1741,7 +1741,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_ras[] __read_mostly = {
 		.name			= "RAS",
 		.me			= THIS_MODULE,
 		.tuple.src.l3num	= AF_INET,
-		.tuple.src.u.udp.port	= __constant_htons(RAS_PORT),
+		.tuple.src.u.udp.port	= cpu_to_be16(RAS_PORT),
 		.tuple.dst.protonum	= IPPROTO_UDP,
 		.help			= ras_help,
 		.expect_policy		= &ras_exp_policy,
@@ -1750,7 +1750,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_ras[] __read_mostly = {
 		.name			= "RAS",
 		.me			= THIS_MODULE,
 		.tuple.src.l3num	= AF_INET6,
-		.tuple.src.u.udp.port	= __constant_htons(RAS_PORT),
+		.tuple.src.u.udp.port	= cpu_to_be16(RAS_PORT),
 		.tuple.dst.protonum	= IPPROTO_UDP,
 		.help			= ras_help,
 		.expect_policy		= &ras_exp_policy,
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index 5af4273..8a3875e 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -105,7 +105,7 @@ static struct nf_conntrack_expect_policy exp_policy = {
 static struct nf_conntrack_helper helper __read_mostly = {
 	.name			= "netbios-ns",
 	.tuple.src.l3num	= AF_INET,
-	.tuple.src.u.udp.port	= __constant_htons(NMBD_PORT),
+	.tuple.src.u.udp.port	= cpu_to_be16(NMBD_PORT),
 	.tuple.dst.protonum	= IPPROTO_UDP,
 	.me			= THIS_MODULE,
 	.help			= help,
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 9e169ef..72cca63 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -591,7 +591,7 @@ static struct nf_conntrack_helper pptp __read_mostly = {
 	.name			= "pptp",
 	.me			= THIS_MODULE,
 	.tuple.src.l3num	= AF_INET,
-	.tuple.src.u.tcp.port	= __constant_htons(PPTP_CONTROL_PORT),
+	.tuple.src.u.tcp.port	= cpu_to_be16(PPTP_CONTROL_PORT),
 	.tuple.dst.protonum	= IPPROTO_TCP,
 	.help			= conntrack_pptp_help,
 	.destroy		= pptp_destroy_siblings,
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 95bc49d..81795ea 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -383,7 +383,7 @@ out:
 }
 
 static struct packet_type phonet_packet_type = {
-	.type = __constant_htons(ETH_P_PHONET),
+	.type = cpu_to_be16(ETH_P_PHONET),
 	.dev = NULL,
 	.func = phonet_rcv,
 };
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 7363935..47bfba6 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -367,7 +367,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	struct sctp_transport *tp = packet->transport;
 	struct sctp_association *asoc = tp->asoc;
 	struct sctphdr *sh;
-	__be32 crc32 = __constant_cpu_to_be32(0);
+	__be32 crc32 = cpu_to_be32(0);
 	struct sk_buff *nskb;
 	struct sctp_chunk *chunk, *tmp;
 	struct sock *sk;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fd8acb4..b40e95f 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -100,11 +100,11 @@ int sctp_chunk_iif(const struct sctp_chunk *chunk)
  */
 static const struct sctp_paramhdr ecap_param = {
 	SCTP_PARAM_ECN_CAPABLE,
-	__constant_htons(sizeof(struct sctp_paramhdr)),
+	cpu_to_be16(sizeof(struct sctp_paramhdr)),
 };
 static const struct sctp_paramhdr prsctp_param = {
 	SCTP_PARAM_FWD_TSN_SUPPORT,
-	__constant_htons(sizeof(struct sctp_paramhdr)),
+	cpu_to_be16(sizeof(struct sctp_paramhdr)),
 };
 
 /* A helper to initialize to initialize an op error inside a
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 9fc5b02..8f76f40 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1609,7 +1609,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) = {
 SOCKOPS_WRAP(x25_proto, AF_X25);
 
 static struct packet_type x25_packet_type = {
-	.type =	__constant_htons(ETH_P_X25),
+	.type =	cpu_to_be16(ETH_P_X25),
 	.func =	x25_lapb_receive_frame,
 };
 
-- 
1.6.1.401.gf39d5

