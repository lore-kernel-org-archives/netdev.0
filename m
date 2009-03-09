From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: convert usage of packet_type to read_mostly
Date: Mon, 9 Mar 2009 11:18:29 -0700
Message-ID: <20090309111829.297ead22@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49514 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394AbZCISSe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 14:18:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Protocols that use packet_type can be __read_mostly section for better
locality. Elminate any unnecessary initializations of NULL.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6

 drivers/block/aoe/aoenet.c      |    2 +-
 drivers/net/hamradio/bpqether.c |    2 +-
 drivers/net/pppoe.c             |    6 +++---
 drivers/net/wan/hdlc.c          |    2 +-
 drivers/net/wan/lapbether.c     |    2 +-
 net/8021q/vlan.c                |    2 +-
 net/appletalk/ddp.c             |    4 ++--
 net/ax25/af_ax25.c              |    3 +--
 net/decnet/af_decnet.c          |    3 +--
 net/dsa/tag_dsa.c               |    2 +-
 net/dsa/tag_edsa.c              |    2 +-
 net/dsa/tag_trailer.c           |    2 +-
 net/econet/af_econet.c          |    2 +-
 net/ipv4/af_inet.c              |    2 +-
 net/ipv4/arp.c                  |    2 +-
 net/ipv6/af_inet6.c             |    2 +-
 net/ipx/af_ipx.c                |    4 ++--
 net/irda/irmod.c                |    2 +-
 net/llc/llc_core.c              |    4 ++--
 net/phonet/af_phonet.c          |    3 +--
 net/x25/af_x25.c                |    2 +-
 21 files changed, 26 insertions(+), 29 deletions(-)

--- a/drivers/block/aoe/aoenet.c	2009-03-09 09:43:40.160185325 -0700
+++ b/drivers/block/aoe/aoenet.c	2009-03-09 09:44:22.876372397 -0700
@@ -151,7 +151,7 @@ exit:
 	return 0;
 }
 
-static struct packet_type aoe_pt = {
+static struct packet_type aoe_pt __read_mostly = {
 	.type = __constant_htons(ETH_P_AOE),
 	.func = aoenet_rcv,
 };
--- a/drivers/net/pppoe.c	2009-03-09 09:43:40.165246373 -0700
+++ b/drivers/net/pppoe.c	2009-03-09 09:44:22.876372397 -0700
@@ -513,17 +513,17 @@ out:
 	return NET_RX_SUCCESS; /* Lies... :-) */
 }
 
-static struct packet_type pppoes_ptype = {
+static struct packet_type pppoes_ptype __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_PPP_SES),
 	.func	= pppoe_rcv,
 };
 
-static struct packet_type pppoed_ptype = {
+static struct packet_type pppoed_ptype __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_PPP_DISC),
 	.func	= pppoe_disc_rcv,
 };
 
-static struct proto pppoe_sk_proto = {
+static struct proto pppoe_sk_proto __read_mostly = {
 	.name	  = "PPPOE",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct pppox_sock),
--- a/drivers/net/wan/hdlc.c	2009-03-09 09:43:40.170246385 -0700
+++ b/drivers/net/wan/hdlc.c	2009-03-09 09:44:22.877372392 -0700
@@ -348,7 +348,7 @@ EXPORT_SYMBOL(unregister_hdlc_protocol);
 EXPORT_SYMBOL(attach_hdlc_protocol);
 EXPORT_SYMBOL(detach_hdlc_protocol);
 
-static struct packet_type hdlc_packet_type = {
+static struct packet_type hdlc_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_HDLC),
 	.func = hdlc_rcv,
 };
--- a/net/8021q/vlan.c	2009-03-09 09:43:40.086121449 -0700
+++ b/net/8021q/vlan.c	2009-03-09 09:44:22.878373324 -0700
@@ -51,7 +51,7 @@ const char vlan_version[] = DRV_VERSION;
 static const char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
 static const char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
-static struct packet_type vlan_packet_type = {
+static struct packet_type vlan_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_8021Q),
 	.func = vlan_skb_recv, /* VLAN receive method */
 };
--- a/net/ax25/af_ax25.c	2009-03-09 09:43:40.125024482 -0700
+++ b/net/ax25/af_ax25.c	2009-03-09 09:44:22.879372577 -0700
@@ -1985,9 +1985,8 @@ static const struct proto_ops ax25_proto
 /*
  *	Called by socket.c on kernel start up
  */
-static struct packet_type ax25_packet_type = {
+static struct packet_type ax25_packet_type __read_mostly = {
 	.type	=	cpu_to_be16(ETH_P_AX25),
-	.dev	=	NULL,				/* All devices */
 	.func	=	ax25_kiss_rcv,
 };
 
--- a/drivers/net/wan/lapbether.c	2009-03-09 09:43:40.175246372 -0700
+++ b/drivers/net/wan/lapbether.c	2009-03-09 09:44:22.880001567 -0700
@@ -421,7 +421,7 @@ static int lapbeth_device_event(struct n
 
 /* ------------------------------------------------------------------------ */
 
-static struct packet_type lapbeth_packet_type = {
+static struct packet_type lapbeth_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_DEC),
 	.func = lapbeth_rcv,
 };
--- a/net/appletalk/ddp.c	2009-03-09 09:43:40.142184792 -0700
+++ b/net/appletalk/ddp.c	2009-03-09 09:44:22.880001567 -0700
@@ -1860,12 +1860,12 @@ static struct notifier_block ddp_notifie
 	.notifier_call	= ddp_device_event,
 };
 
-static struct packet_type ltalk_packet_type = {
+static struct packet_type ltalk_packet_type __read_mostly = {
 	.type		= cpu_to_be16(ETH_P_LOCALTALK),
 	.func		= ltalk_rcv,
 };
 
-static struct packet_type ppptalk_packet_type = {
+static struct packet_type ppptalk_packet_type __read_mostly = {
 	.type		= cpu_to_be16(ETH_P_PPPTALK),
 	.func		= atalk_rcv,
 };
--- a/net/dsa/tag_dsa.c	2009-03-09 09:43:40.091122061 -0700
+++ b/net/dsa/tag_dsa.c	2009-03-09 09:44:22.881372201 -0700
@@ -175,7 +175,7 @@ out:
 	return 0;
 }
 
-static struct packet_type dsa_packet_type = {
+static struct packet_type dsa_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_DSA),
 	.func	= dsa_rcv,
 };
--- a/net/dsa/tag_edsa.c	2009-03-09 09:43:40.102122541 -0700
+++ b/net/dsa/tag_edsa.c	2009-03-09 09:44:22.881372201 -0700
@@ -194,7 +194,7 @@ out:
 	return 0;
 }
 
-static struct packet_type edsa_packet_type = {
+static struct packet_type edsa_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_EDSA),
 	.func	= edsa_rcv,
 };
--- a/net/dsa/tag_trailer.c	2009-03-09 09:43:40.096122310 -0700
+++ b/net/dsa/tag_trailer.c	2009-03-09 09:44:22.881372201 -0700
@@ -111,7 +111,7 @@ out:
 	return 0;
 }
 
-static struct packet_type trailer_packet_type = {
+static struct packet_type trailer_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_TRAILER),
 	.func	= trailer_rcv,
 };
--- a/net/econet/af_econet.c	2009-03-09 09:43:40.113122606 -0700
+++ b/net/econet/af_econet.c	2009-03-09 09:44:22.882372380 -0700
@@ -1102,7 +1102,7 @@ drop:
 	return NET_RX_DROP;
 }
 
-static struct packet_type econet_packet_type = {
+static struct packet_type econet_packet_type __read_mostly = {
 	.type =		cpu_to_be16(ETH_P_ECONET),
 	.func =		econet_rcv,
 };
--- a/net/ipv4/af_inet.c	2009-03-09 09:43:40.153185267 -0700
+++ b/net/ipv4/af_inet.c	2009-03-09 09:44:22.883002825 -0700
@@ -1500,7 +1500,7 @@ static int ipv4_proc_init(void);
  *	IP protocol layer initialiser
  */
 
-static struct packet_type ip_packet_type = {
+static struct packet_type ip_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
 	.func = ip_rcv,
 	.gso_send_check = inet_gso_send_check,
--- a/net/ipv4/arp.c	2009-03-09 09:43:40.147184736 -0700
+++ b/net/ipv4/arp.c	2009-03-09 09:44:22.884372318 -0700
@@ -1225,7 +1225,7 @@ void arp_ifdown(struct net_device *dev)
  *	Called once on startup.
  */
 
-static struct packet_type arp_packet_type = {
+static struct packet_type arp_packet_type __read_mostly = {
 	.type =	cpu_to_be16(ETH_P_ARP),
 	.func =	arp_rcv,
 };
--- a/net/ipv6/af_inet6.c	2009-03-09 09:43:40.131121332 -0700
+++ b/net/ipv6/af_inet6.c	2009-03-09 09:44:22.884372318 -0700
@@ -893,7 +893,7 @@ out_unlock:
 	return err;
 }
 
-static struct packet_type ipv6_packet_type = {
+static struct packet_type ipv6_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.func = ipv6_rcv,
 	.gso_send_check = ipv6_gso_send_check,
--- a/net/ipx/af_ipx.c	2009-03-09 09:43:40.108121400 -0700
+++ b/net/ipx/af_ipx.c	2009-03-09 09:44:22.885372280 -0700
@@ -1958,12 +1958,12 @@ static const struct proto_ops SOCKOPS_WR
 
 SOCKOPS_WRAP(ipx_dgram, PF_IPX);
 
-static struct packet_type ipx_8023_packet_type = {
+static struct packet_type ipx_8023_packet_type __read_mostly = {
 	.type		= cpu_to_be16(ETH_P_802_3),
 	.func		= ipx_rcv,
 };
 
-static struct packet_type ipx_dix_packet_type = {
+static struct packet_type ipx_dix_packet_type __read_mostly = {
 	.type		= cpu_to_be16(ETH_P_IPX),
 	.func		= ipx_rcv,
 };
--- a/net/llc/llc_core.c	2009-03-09 09:43:40.081121598 -0700
+++ b/net/llc/llc_core.c	2009-03-09 09:44:22.886372276 -0700
@@ -147,12 +147,12 @@ void llc_sap_close(struct llc_sap *sap)
 	kfree(sap);
 }
 
-static struct packet_type llc_packet_type = {
+static struct packet_type llc_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_802_2),
 	.func = llc_rcv,
 };
 
-static struct packet_type llc_tr_packet_type = {
+static struct packet_type llc_tr_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_TR_802_2),
 	.func = llc_rcv,
 };
--- a/net/phonet/af_phonet.c	2009-03-09 09:43:40.136123098 -0700
+++ b/net/phonet/af_phonet.c	2009-03-09 09:44:22.886372276 -0700
@@ -382,9 +382,8 @@ out:
 	return NET_RX_DROP;
 }
 
-static struct packet_type phonet_packet_type = {
+static struct packet_type phonet_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_PHONET),
-	.dev = NULL,
 	.func = phonet_rcv,
 };
 
--- a/net/x25/af_x25.c	2009-03-09 09:43:40.119121618 -0700
+++ b/net/x25/af_x25.c	2009-03-09 09:44:22.887372330 -0700
@@ -1608,7 +1608,7 @@ static const struct proto_ops SOCKOPS_WR
 
 SOCKOPS_WRAP(x25_proto, AF_X25);
 
-static struct packet_type x25_packet_type = {
+static struct packet_type x25_packet_type __read_mostly = {
 	.type =	cpu_to_be16(ETH_P_X25),
 	.func =	x25_lapb_receive_frame,
 };
--- a/drivers/net/hamradio/bpqether.c	2009-03-09 09:43:40.183246210 -0700
+++ b/drivers/net/hamradio/bpqether.c	2009-03-09 09:44:22.888372259 -0700
@@ -97,7 +97,7 @@ static char bpq_eth_addr[6];
 static int bpq_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
 static int bpq_device_event(struct notifier_block *, unsigned long, void *);
 
-static struct packet_type bpq_packet_type = {
+static struct packet_type bpq_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_BPQ),
 	.func	= bpq_rcv,
 };
--- a/net/decnet/af_decnet.c	2009-03-09 09:44:55.943434191 -0700
+++ b/net/decnet/af_decnet.c	2009-03-09 09:45:10.948014560 -0700
@@ -2112,9 +2112,8 @@ static struct notifier_block dn_dev_noti
 
 extern int dn_route_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
 
-static struct packet_type dn_dix_packet_type = {
+static struct packet_type dn_dix_packet_type __read_mostly = {
 	.type =		cpu_to_be16(ETH_P_DNA_RT),
-	.dev =		NULL,		/* All devices */
 	.func =		dn_route_rcv,
 };
 
--- a/net/irda/irmod.c	2009-03-09 09:44:33.092372164 -0700
+++ b/net/irda/irmod.c	2009-03-09 09:44:44.340242320 -0700
@@ -55,7 +55,7 @@ EXPORT_SYMBOL(irda_debug);
 /* Packet type handler.
  * Tell the kernel how IrDA packets should be handled.
  */
-static struct packet_type irda_packet_type = {
+static struct packet_type irda_packet_type __read_mostly = {
 	.type	= cpu_to_be16(ETH_P_IRDA),
 	.func	= irlap_driver_rcv,	/* Packet type handler irlap_frame.c */
 };
