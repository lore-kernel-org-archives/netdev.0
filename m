From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 8/8] net: get rid of orig_dev parameter of packet handlers
Date: Sat,  5 Mar 2011 11:29:29 +0100
Message-ID: <1299320969-7951-9-git-send-email-jpirko@redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4749 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501Ab1CEK3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 05:29:53 -0500
In-Reply-To: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since orig_dev was used in af_packet (where it was replaced) and by
bonding ptype handlers (which are no longer with us) only, orig_dev
parameter is no longer needed -> toss it out

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/block/aoe/aoenet.c      |    2 +-
 drivers/net/hamradio/bpqether.c |    4 ++--
 drivers/net/pppoe.c             |    4 ++--
 drivers/net/wan/hdlc.c          |    2 +-
 drivers/net/wan/lapbether.c     |    2 +-
 drivers/scsi/fcoe/fcoe.c        |   12 ++++--------
 include/linux/netdevice.h       |    3 +--
 include/net/ax25.h              |    3 ++-
 include/net/datalink.h          |    2 +-
 include/net/ip.h                |    2 +-
 include/net/ipv6.h              |    3 +--
 include/net/irda/irda.h         |    3 +--
 include/net/llc.h               |    8 +++-----
 include/net/p8022.h             |    3 +--
 include/net/psnap.h             |    3 +--
 include/net/x25.h               |    2 +-
 net/802/p8022.c                 |    3 +--
 net/802/psnap.c                 |    7 +++----
 net/802/stp.c                   |    2 +-
 net/8021q/vlan.h                |    2 +-
 net/8021q/vlan_dev.c            |    2 +-
 net/appletalk/aarp.c            |    2 +-
 net/appletalk/ddp.c             |    6 +++---
 net/ax25/ax25_in.c              |    2 +-
 net/batman-adv/hard-interface.c |    6 ++----
 net/caif/caif_dev.c             |    2 +-
 net/can/af_can.c                |    2 +-
 net/core/dev.c                  |   26 ++++++++++++--------------
 net/core/skbuff.c               |    1 -
 net/decnet/af_decnet.c          |    2 +-
 net/decnet/dn_route.c           |    2 +-
 net/dsa/tag_dsa.c               |    2 +-
 net/dsa/tag_edsa.c              |    2 +-
 net/dsa/tag_trailer.c           |    2 +-
 net/econet/af_econet.c          |    2 +-
 net/ieee802154/af_ieee802154.c  |    2 +-
 net/ipv4/arp.c                  |    2 +-
 net/ipv4/ip_input.c             |    2 +-
 net/ipv4/ipconfig.c             |   13 ++++++++-----
 net/ipv6/ip6_input.c            |    3 ++-
 net/ipx/af_ipx.c                |    3 ++-
 net/irda/irlap_frame.c          |    2 +-
 net/llc/llc_core.c              |    3 +--
 net/llc/llc_input.c             |    8 ++++----
 net/packet/af_packet.c          |    6 +++---
 net/phonet/af_phonet.c          |    3 +--
 net/tipc/eth_media.c            |    2 +-
 net/x25/x25_dev.c               |    2 +-
 48 files changed, 85 insertions(+), 99 deletions(-)

diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
index 4d3bc0d..c12e14b 100644
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -99,7 +99,7 @@ aoenet_xmit(struct sk_buff_head *queue)
  * (1) len doesn't include the header by default.  I want this. 
  */
 static int
-aoenet_rcv(struct sk_buff *skb, struct net_device *ifp, struct packet_type *pt, struct net_device *orig_dev)
+aoenet_rcv(struct sk_buff *skb, struct net_device *ifp, struct packet_type *pt)
 {
 	struct aoe_hdr *h;
 	u32 n;
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 8931168..f17ca33 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -95,7 +95,7 @@ static char bcast_addr[6]={0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};
 
 static char bpq_eth_addr[6];
 
-static int bpq_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
+static int bpq_rcv(struct sk_buff *, struct net_device *, struct packet_type *);
 static int bpq_device_event(struct notifier_block *, unsigned long, void *);
 
 static struct packet_type bpq_packet_type __read_mostly = {
@@ -177,7 +177,7 @@ static inline int dev_is_ethdev(struct net_device *dev)
 /*
  *	Receive an AX.25 frame via an ethernet interface.
  */
-static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *ptype, struct net_device *orig_dev)
+static int bpq_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *ptype)
 {
 	int len;
 	char * ptr;
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 78c0e3c..b99cdaa 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -419,7 +419,7 @@ abort_kfree:
  *
  ***********************************************************************/
 static int pppoe_rcv(struct sk_buff *skb, struct net_device *dev,
-		     struct packet_type *pt, struct net_device *orig_dev)
+		     struct packet_type *pt)
 {
 	struct pppoe_hdr *ph;
 	struct pppox_sock *po;
@@ -467,7 +467,7 @@ out:
  *
  ***********************************************************************/
 static int pppoe_disc_rcv(struct sk_buff *skb, struct net_device *dev,
-			  struct packet_type *pt, struct net_device *orig_dev)
+			  struct packet_type *pt)
 
 {
 	struct pppoe_hdr *ph;
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 5d4bb61..0ac4f27 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -53,7 +53,7 @@ int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *p, struct net_device *orig_dev)
+		    struct packet_type *p)
 {
 	struct hdlc_device *hdlc = dev_to_hdlc(dev);
 
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 7f5bb91..993d71a 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -86,7 +86,7 @@ static __inline__ int dev_is_ethdev(struct net_device *dev)
 /*
  *	Receive a LAPB frame via an ethernet interface.
  */
-static int lapbeth_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *ptype, struct net_device *orig_dev)
+static int lapbeth_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *ptype)
 {
 	int len, err;
 	struct lapbethdev *lapbeth;
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 3becc6a..d7442b6 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -70,7 +70,7 @@ DEFINE_PER_CPU(struct fcoe_percpu_s, fcoe_percpu);
 static int fcoe_reset(struct Scsi_Host *);
 static int fcoe_xmit(struct fc_lport *, struct fc_frame *);
 static int fcoe_rcv(struct sk_buff *, struct net_device *,
-		    struct packet_type *, struct net_device *);
+		    struct packet_type *);
 static int fcoe_percpu_receive_thread(void *);
 static void fcoe_clean_pending_queue(struct fc_lport *);
 static void fcoe_percpu_clean(struct fc_lport *);
@@ -88,7 +88,7 @@ static struct fcoe_interface
 *fcoe_hostlist_lookup_port(const struct net_device *);
 
 static int fcoe_fip_recv(struct sk_buff *, struct net_device *,
-			 struct packet_type *, struct net_device *);
+			 struct packet_type *);
 
 static void fcoe_fip_send(struct fcoe_ctlr *, struct sk_buff *);
 static void fcoe_update_src_mac(struct fc_lport *, u8 *);
@@ -465,14 +465,11 @@ static inline void fcoe_interface_put(struct fcoe_interface *fcoe)
  * @skb:      The receive skb
  * @netdev:   The associated net device
  * @ptype:    The packet_type structure which was used to register this handler
- * @orig_dev: The original net_device the the skb was received on.
- *	      (in case dev is a bond)
  *
  * Returns: 0 for success
  */
 static int fcoe_fip_recv(struct sk_buff *skb, struct net_device *netdev,
-			 struct packet_type *ptype,
-			 struct net_device *orig_dev)
+			 struct packet_type *ptype)
 {
 	struct fcoe_interface *fcoe;
 
@@ -1228,7 +1225,6 @@ static int fcoe_cpu_callback(struct notifier_block *nfb,
  * @skb:    The received packet
  * @netdev: The net device that the packet was received on
  * @ptype:  The packet type context
- * @olddev: The last device net device
  *
  * This routine is called by NET_RX_SOFTIRQ. It receives a packet, builds a
  * FC frame and passes the frame to libfc.
@@ -1236,7 +1232,7 @@ static int fcoe_cpu_callback(struct notifier_block *nfb,
  * Returns: 0 for success
  */
 int fcoe_rcv(struct sk_buff *skb, struct net_device *netdev,
-	     struct packet_type *ptype, struct net_device *olddev)
+	     struct packet_type *ptype)
 {
 	struct fc_lport *lport;
 	struct fcoe_rcv_info *fr;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ff386a4..48a9638 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1456,8 +1456,7 @@ struct packet_type {
 	struct net_device	*dev;	/* NULL is wildcarded here	     */
 	int			(*func) (struct sk_buff *,
 					 struct net_device *,
-					 struct packet_type *,
-					 struct net_device *);
+					 struct packet_type *);
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
 						u32 features);
 	int			(*gso_send_check)(struct sk_buff *skb);
diff --git a/include/net/ax25.h b/include/net/ax25.h
index 206d222..fcbe6d8 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -362,7 +362,8 @@ extern int  ax25_protocol_is_registered(unsigned int);
 
 /* ax25_in.c */
 extern int  ax25_rx_iframe(ax25_cb *, struct sk_buff *);
-extern int  ax25_kiss_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
+extern int  ax25_kiss_rcv(struct sk_buff *, struct net_device *,
+			  struct packet_type *);
 
 /* ax25_ip.c */
 extern int ax25_hard_header(struct sk_buff *, struct net_device *,
diff --git a/include/net/datalink.h b/include/net/datalink.h
index deb7ca7..5797ba3 100644
--- a/include/net/datalink.h
+++ b/include/net/datalink.h
@@ -9,7 +9,7 @@ struct datalink_proto {
         unsigned short  header_length;
 
         int     (*rcvfunc)(struct sk_buff *, struct net_device *,
-                                struct packet_type *, struct net_device *);
+                                struct packet_type *);
 	int     (*request)(struct datalink_proto *, struct sk_buff *,
                                         unsigned char *);
 	struct list_head node;
diff --git a/include/net/ip.h b/include/net/ip.h
index a4f6311..3b04c24 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -94,7 +94,7 @@ extern int		ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 					      __be32 saddr, __be32 daddr,
 					      struct ip_options *opt);
 extern int		ip_rcv(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt, struct net_device *orig_dev);
+			       struct packet_type *pt);
 extern int		ip_local_deliver(struct sk_buff *skb);
 extern int		ip_mr_input(struct sk_buff *skb);
 extern int		ip_output(struct sk_buff *skb);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d6d077d..990f90b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -470,8 +470,7 @@ static __inline__ void ipv6_select_ident(struct frag_hdr *fhdr)
 
 extern int			ipv6_rcv(struct sk_buff *skb, 
 					 struct net_device *dev, 
-					 struct packet_type *pt,
-					 struct net_device *orig_dev);
+					 struct packet_type *pt);
 
 extern int			ip6_rcv_finish(struct sk_buff *skb);
 
diff --git a/include/net/irda/irda.h b/include/net/irda/irda.h
index 3bed61d..2c6e25d 100644
--- a/include/net/irda/irda.h
+++ b/include/net/irda/irda.h
@@ -125,7 +125,6 @@ extern int irda_nl_register(void);
 extern void irda_nl_unregister(void);
 
 extern int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
-			    struct packet_type *ptype,
-			    struct net_device *orig_dev);
+			    struct packet_type *ptype);
 
 #endif /* NET_IRDA_H */
diff --git a/include/net/llc.h b/include/net/llc.h
index 5503b74..73bfea5 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -58,8 +58,7 @@ struct llc_sap {
 	atomic_t         refcnt;
 	int		 (*rcv_func)(struct sk_buff *skb,
 				     struct net_device *dev,
-				     struct packet_type *pt,
-				     struct net_device *orig_dev);
+				     struct packet_type *pt);
 	struct llc_addr	 laddr;
 	struct list_head node;
 	spinlock_t sk_lock;
@@ -96,7 +95,7 @@ extern struct list_head llc_sap_list;
 extern spinlock_t llc_sap_list_lock;
 
 extern int llc_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev);
+		   struct packet_type *pt);
 
 extern int llc_mac_hdr_init(struct sk_buff *skb,
 			    const unsigned char *sa, const unsigned char *da);
@@ -110,8 +109,7 @@ extern void llc_set_station_handler(void (*handler)(struct sk_buff *skb));
 extern struct llc_sap *llc_sap_open(unsigned char lsap,
 				    int (*rcv)(struct sk_buff *skb,
 					       struct net_device *dev,
-					       struct packet_type *pt,
-					       struct net_device *orig_dev));
+					       struct packet_type *pt));
 static inline void llc_sap_hold(struct llc_sap *sap)
 {
 	atomic_inc(&sap->refcnt);
diff --git a/include/net/p8022.h b/include/net/p8022.h
index 42e9fac..6d878ae 100644
--- a/include/net/p8022.h
+++ b/include/net/p8022.h
@@ -4,8 +4,7 @@ extern struct datalink_proto *
 	register_8022_client(unsigned char type,
 			     int (*func)(struct sk_buff *skb,
 					 struct net_device *dev,
-					 struct packet_type *pt,
-					 struct net_device *orig_dev));
+					 struct packet_type *pt));
 extern void unregister_8022_client(struct datalink_proto *proto);
 
 extern struct datalink_proto *make_8023_client(void);
diff --git a/include/net/psnap.h b/include/net/psnap.h
index fe456c2..604bf4b 100644
--- a/include/net/psnap.h
+++ b/include/net/psnap.h
@@ -4,8 +4,7 @@
 extern struct datalink_proto *
 register_snap_client(const unsigned char *desc,
 		     int (*rcvfunc)(struct sk_buff *, struct net_device *,
-				    struct packet_type *,
-				    struct net_device *orig_dev));
+				    struct packet_type *));
 extern void unregister_snap_client(struct datalink_proto *proto);
 
 #endif
diff --git a/include/net/x25.h b/include/net/x25.h
index a06119a..3f1c0df2 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -202,7 +202,7 @@ extern void x25_kill_by_neigh(struct x25_neigh *);
 
 /* x25_dev.c */
 extern void x25_send_frame(struct sk_buff *, struct x25_neigh *);
-extern int  x25_lapb_receive_frame(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
+extern int  x25_lapb_receive_frame(struct sk_buff *, struct net_device *, struct packet_type *);
 extern void x25_establish_link(struct x25_neigh *);
 extern void x25_terminate_link(struct x25_neigh *);
 
diff --git a/net/802/p8022.c b/net/802/p8022.c
index 7f353c4..4ab1339 100644
--- a/net/802/p8022.c
+++ b/net/802/p8022.c
@@ -36,8 +36,7 @@ static int p8022_request(struct datalink_proto *dl, struct sk_buff *skb,
 struct datalink_proto *register_8022_client(unsigned char type,
 					    int (*func)(struct sk_buff *skb,
 							struct net_device *dev,
-							struct packet_type *pt,
-							struct net_device *orig_dev))
+							struct packet_type *pt))
 {
 	struct datalink_proto *proto;
 
diff --git a/net/802/psnap.c b/net/802/psnap.c
index 21cde8f..e74b48e 100644
--- a/net/802/psnap.c
+++ b/net/802/psnap.c
@@ -47,7 +47,7 @@ static struct datalink_proto *find_snap_client(const unsigned char *desc)
  *	A SNAP packet has arrived
  */
 static int snap_rcv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
+		    struct packet_type *pt)
 {
 	int rc = 1;
 	struct datalink_proto *proto;
@@ -64,7 +64,7 @@ static int snap_rcv(struct sk_buff *skb, struct net_device *dev,
 		/* Pass the frame on. */
 		skb->transport_header += 5;
 		skb_pull_rcsum(skb, 5);
-		rc = proto->rcvfunc(skb, dev, &snap_packet_type, orig_dev);
+		rc = proto->rcvfunc(skb, dev, &snap_packet_type);
 	}
 	rcu_read_unlock();
 
@@ -126,8 +126,7 @@ module_exit(snap_exit);
 struct datalink_proto *register_snap_client(const unsigned char *desc,
 					    int (*rcvfunc)(struct sk_buff *,
 							   struct net_device *,
-							   struct packet_type *,
-							   struct net_device *))
+							   struct packet_type *))
 {
 	struct datalink_proto *proto = NULL;
 
diff --git a/net/802/stp.c b/net/802/stp.c
index 978c30b..dec1f88 100644
--- a/net/802/stp.c
+++ b/net/802/stp.c
@@ -30,7 +30,7 @@ static DEFINE_MUTEX(stp_proto_mutex);
 
 /* Called under rcu_read_lock from LLC */
 static int stp_pdu_rcv(struct sk_buff *skb, struct net_device *dev,
-		       struct packet_type *pt, struct net_device *orig_dev)
+		       struct packet_type *pt)
 {
 	const struct ethhdr *eh = eth_hdr(skb);
 	const struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5687c9b..6f8941e 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -76,7 +76,7 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 
 /* found in vlan_dev.c */
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		  struct packet_type *ptype, struct net_device *orig_dev);
+		  struct packet_type *ptype);
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, u16 vlan_prio);
 int vlan_dev_set_egress_priority(const struct net_device *dev,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index be73753..6e396b9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -138,7 +138,7 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
  *
  */
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
-		  struct packet_type *ptype, struct net_device *orig_dev)
+		  struct packet_type *ptype)
 {
 	struct vlan_hdr *vhdr;
 	struct vlan_pcpu_stats *rx_stats;
diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 50dce79..996f366 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -715,7 +715,7 @@ static void __aarp_resolved(struct aarp_entry **list, struct aarp_entry *a,
  *	frame. We currently only support Ethernet.
  */
 static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
+		    struct packet_type *pt)
 {
 	struct elapaarp *ea = aarp_hdr(skb);
 	int hash, ret = 0;
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index c410b93..61b4983 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1425,7 +1425,7 @@ drop:
  *	layer.  [ie ARPHRD_ETHERTALK]
  */
 static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
-		     struct packet_type *pt, struct net_device *orig_dev)
+		     struct packet_type *pt)
 {
 	struct ddpehdr *ddp;
 	struct sock *sock;
@@ -1522,7 +1522,7 @@ out:
  * header and append a long one.
  */
 static int ltalk_rcv(struct sk_buff *skb, struct net_device *dev,
-		     struct packet_type *pt, struct net_device *orig_dev)
+		     struct packet_type *pt)
 {
 	if (!net_eq(dev_net(dev), &init_net))
 		goto freeit;
@@ -1568,7 +1568,7 @@ static int ltalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 	skb_reset_transport_header(skb);
 
-	return atalk_rcv(skb, dev, pt, orig_dev);
+	return atalk_rcv(skb, dev, pt);
 freeit:
 	kfree_skb(skb);
 	return 0;
diff --git a/net/ax25/ax25_in.c b/net/ax25/ax25_in.c
index 9bb7765..f6f94e6 100644
--- a/net/ax25/ax25_in.c
+++ b/net/ax25/ax25_in.c
@@ -436,7 +436,7 @@ free:
  *	Receive an AX.25 frame via a SLIP interface.
  */
 int ax25_kiss_rcv(struct sk_buff *skb, struct net_device *dev,
-		  struct packet_type *ptype, struct net_device *orig_dev)
+		  struct packet_type *ptype)
 {
 	skb_orphan(skb);
 
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index f2131f4..08579b0 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -37,8 +37,7 @@ static DEFINE_SPINLOCK(if_list_lock);
 
 static int batman_skb_recv(struct sk_buff *skb,
 			   struct net_device *dev,
-			   struct packet_type *ptype,
-			   struct net_device *orig_dev);
+			   struct packet_type *ptype);
 
 static void hardif_free_rcu(struct rcu_head *rcu)
 {
@@ -556,8 +555,7 @@ out:
 /* receive a packet with the batman ethertype coming on a hard
  * interface */
 static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
-			   struct packet_type *ptype,
-			   struct net_device *orig_dev)
+			   struct packet_type *ptype)
 {
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet;
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index a42a408..9f016f0 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -165,7 +165,7 @@ static int modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
  * On error, returns non-zero and releases the skb.
  */
 static int receive(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pkttype, struct net_device *orig_dev)
+		   struct packet_type *pkttype)
 {
 	struct net *net;
 	struct cfpkt *pkt;
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 702be5a..ad32de5 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -616,7 +616,7 @@ static int can_rcv_filter(struct dev_rcv_lists *d, struct sk_buff *skb)
 }
 
 static int can_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev)
+		   struct packet_type *pt)
 {
 	struct dev_rcv_lists *d;
 	struct can_frame *cf = (struct can_frame *)skb->data;
diff --git a/net/core/dev.c b/net/core/dev.c
index 58daddb..c71bd18 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1534,11 +1534,10 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 EXPORT_SYMBOL_GPL(dev_forward_skb);
 
 static inline int deliver_skb(struct sk_buff *skb,
-			      struct packet_type *pt_prev,
-			      struct net_device *orig_dev)
+			      struct packet_type *pt_prev)
 {
 	atomic_inc(&skb->users);
-	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+	return pt_prev->func(skb, skb->dev, pt_prev);
 }
 
 /*
@@ -1561,7 +1560,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		    (ptype->af_packet_priv == NULL ||
 		     (struct sock *)ptype->af_packet_priv != skb->sk)) {
 			if (pt_prev) {
-				deliver_skb(skb2, pt_prev, skb->dev);
+				deliver_skb(skb2, pt_prev);
 				pt_prev = ptype;
 				continue;
 			}
@@ -1594,7 +1593,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 	if (pt_prev)
-		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
+		pt_prev->func(skb2, skb->dev, pt_prev);
 	rcu_read_unlock();
 }
 
@@ -3025,8 +3024,7 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 }
 
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
-					 struct packet_type **pt_prev,
-					 int *ret, struct net_device *orig_dev)
+					 struct packet_type **pt_prev, int *ret)
 {
 	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
 
@@ -3034,7 +3032,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		goto out;
 
 	if (*pt_prev) {
-		*ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*ret = deliver_skb(skb, *pt_prev);
 		*pt_prev = NULL;
 	}
 
@@ -3160,13 +3158,13 @@ another_round:
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		if (!ptype->dev || ptype->dev == skb->dev) {
 			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
+				ret = deliver_skb(skb, pt_prev);
 			pt_prev = ptype;
 		}
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
-	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
+	skb = handle_ing(skb, &pt_prev, &ret);
 	if (!skb)
 		goto out;
 ncls:
@@ -3175,7 +3173,7 @@ ncls:
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {
 		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
+			ret = deliver_skb(skb, pt_prev);
 			pt_prev = NULL;
 		}
 		switch (rx_handler(&skb)) {
@@ -3194,7 +3192,7 @@ ncls:
 
 	if (vlan_tx_tag_present(skb)) {
 		if (pt_prev) {
-			ret = deliver_skb(skb, pt_prev, orig_dev);
+			ret = deliver_skb(skb, pt_prev);
 			pt_prev = NULL;
 		}
 		if (vlan_hwaccel_do_receive(&skb)) {
@@ -3216,13 +3214,13 @@ ncls:
 		    (ptype->dev == null_or_dev || ptype->dev == skb->dev ||
 		     ptype->dev == orig_dev)) {
 			if (pt_prev)
-				ret = deliver_skb(skb, pt_prev, orig_dev);
+				ret = deliver_skb(skb, pt_prev);
 			pt_prev = ptype;
 		}
 	}
 
 	if (pt_prev) {
-		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		ret = pt_prev->func(skb, skb->dev, pt_prev);
 	} else {
 		atomic_long_inc(&skb->dev->rx_dropped);
 		kfree_skb(skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1eb526a..801dd08 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -523,7 +523,6 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->ip_summed		= old->ip_summed;
 	skb_copy_queue_mapping(new, old);
 	new->priority		= old->priority;
-	new->deliver_no_wcard	= old->deliver_no_wcard;
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	= old->ipvs_property;
 #endif
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2af15b1..1421721 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2106,7 +2106,7 @@ static struct notifier_block dn_dev_notifier = {
 	.notifier_call = dn_device_event,
 };
 
-extern int dn_route_rcv(struct sk_buff *, struct net_device *, struct packet_type *, struct net_device *);
+extern int dn_route_rcv(struct sk_buff *, struct net_device *, struct packet_type *);
 
 static struct packet_type dn_dix_packet_type __read_mostly = {
 	.type =		cpu_to_be16(ETH_P_DNA_RT),
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 484fdbf..20abc79 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -588,7 +588,7 @@ static int dn_route_ptp_hello(struct sk_buff *skb)
 	return NET_RX_SUCCESS;
 }
 
-int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
 {
 	struct dn_skb_cb *cb;
 	unsigned char flags = 0;
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index 98dfe80..56b686e 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -77,7 +77,7 @@ out_free:
 }
 
 static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev)
+		   struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 6f38332..474a955 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -90,7 +90,7 @@ out_free:
 }
 
 static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
+		    struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d6d7d0a..f8f36ad 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -67,7 +67,7 @@ netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
-		       struct packet_type *pt, struct net_device *orig_dev)
+		       struct packet_type *pt)
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_switch *ds;
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 0c28263..edeea09 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -1052,7 +1052,7 @@ release:
  *	Receive an Econet frame from a device.
  */
 
-static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int econet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
 {
 	struct ec_framehdr *hdr;
 	struct sock *sk = NULL;
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 6df6ecf..68d5bce 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -299,7 +299,7 @@ static const struct net_proto_family ieee802154_family_ops = {
 };
 
 static int ieee802154_rcv(struct sk_buff *skb, struct net_device *dev,
-	struct packet_type *pt, struct net_device *orig_dev)
+			  struct packet_type *pt)
 {
 	if (!netif_running(dev))
 		return -ENODEV;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index fa9988d..53a8f14 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -974,7 +974,7 @@ static void parp_redo(struct sk_buff *skb)
  */
 
 static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev)
+		   struct packet_type *pt)
 {
 	struct arphdr *arp;
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d7b2b09..639b69b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -372,7 +372,7 @@ drop:
 /*
  * 	Main IP Receive routine.
  */
-int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt)
 {
 	struct iphdr *iph;
 	u32 len;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 2b09775..5669509 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -438,7 +438,8 @@ static int __init ic_defaults(void)
 
 #ifdef IPCONFIG_RARP
 
-static int ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev);
+static int ic_rarp_recv(struct sk_buff *skb, struct net_device *dev,
+			struct packet_type *pt);
 
 static struct packet_type rarp_packet_type __initdata = {
 	.type =	cpu_to_be16(ETH_P_RARP),
@@ -458,8 +459,8 @@ static inline void __init ic_rarp_cleanup(void)
 /*
  *  Process received RARP packet.
  */
-static int __init
-ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int __init ic_rarp_recv(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt)
 {
 	struct arphdr *rarp;
 	unsigned char *rarp_ptr;
@@ -600,7 +601,8 @@ struct bootp_pkt {		/* BOOTP packet format */
 #define DHCPRELEASE	7
 #define DHCPINFORM	8
 
-static int ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev);
+static int ic_bootp_recv(struct sk_buff *skb, struct net_device *dev
+			 struct packet_type *pt);
 
 static struct packet_type bootp_packet_type __initdata = {
 	.type =	cpu_to_be16(ETH_P_IP),
@@ -893,7 +895,8 @@ static void __init ic_do_bootp_ext(u8 *ext)
 /*
  *  Receive BOOTP reply.
  */
-static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int __init ic_bootp_recv(struct sk_buff *skb, struct net_device *dev,
+				struct packet_type *pt)
 {
 	struct bootp_pkt *b;
 	struct iphdr *h;
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index a83e920..dd72591 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -55,7 +55,8 @@ inline int ip6_rcv_finish( struct sk_buff *skb)
 	return dst_input(skb);
 }
 
-int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+int ipv6_rcv(struct sk_buff *skb, struct net_device *dev,
+	     struct packet_type *pt)
 {
 	struct ipv6hdr *hdr;
 	u32 		pkt_len;
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index da3d21c..614e207 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1665,7 +1665,8 @@ static unsigned int ipx_datagram_poll(struct file *file, struct socket *sock,
 	return rc;
 }
 
-static int ipx_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int ipx_rcv(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt)
 {
 	/* NULL here for pt means the packet was looped back */
 	struct ipx_interface *intrfc;
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 688222c..7850321 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -1306,7 +1306,7 @@ static void irlap_recv_test_frame(struct irlap_cb *self, struct sk_buff *skb,
  * Jean II
  */
 int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
-		     struct packet_type *ptype, struct net_device *orig_dev)
+		     struct packet_type *ptype)
 {
 	struct irlap_info info;
 	struct irlap_cb *self;
diff --git a/net/llc/llc_core.c b/net/llc/llc_core.c
index 2bb0ddf..dfeda38 100644
--- a/net/llc/llc_core.c
+++ b/net/llc/llc_core.c
@@ -91,8 +91,7 @@ struct llc_sap *llc_sap_find(unsigned char sap_value)
 struct llc_sap *llc_sap_open(unsigned char lsap,
 			     int (*func)(struct sk_buff *skb,
 					 struct net_device *dev,
-					 struct packet_type *pt,
-					 struct net_device *orig_dev))
+					 struct packet_type *pt))
 {
 	struct llc_sap *sap = NULL;
 
diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
index 058f1e9..d884e23 100644
--- a/net/llc/llc_input.c
+++ b/net/llc/llc_input.c
@@ -143,13 +143,13 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
  *	data now), it queues this frame in the connection's backlog.
  */
 int llc_rcv(struct sk_buff *skb, struct net_device *dev,
-	    struct packet_type *pt, struct net_device *orig_dev)
+	    struct packet_type *pt)
 {
 	struct llc_sap *sap;
 	struct llc_pdu_sn *pdu;
 	int dest;
 	int (*rcv)(struct sk_buff *, struct net_device *,
-		   struct packet_type *, struct net_device *);
+		   struct packet_type *);
 
 	if (!net_eq(dev_net(dev), &init_net))
 		goto drop;
@@ -184,14 +184,14 @@ int llc_rcv(struct sk_buff *skb, struct net_device *dev,
 	dest = llc_pdu_type(skb);
 	if (unlikely(!dest || !llc_type_handlers[dest - 1])) {
 		if (rcv)
-			rcv(skb, dev, pt, orig_dev);
+			rcv(skb, dev, pt);
 		else
 			kfree_skb(skb);
 	} else {
 		if (rcv) {
 			struct sk_buff *cskb = skb_clone(skb, GFP_ATOMIC);
 			if (cskb)
-				rcv(cskb, dev, pt, orig_dev);
+				rcv(cskb, dev, pt);
 		}
 		llc_type_handlers[dest - 1](sap, skb);
 	}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b34294e..85e2493 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -350,7 +350,7 @@ static const struct proto_ops packet_ops;
 static const struct proto_ops packet_ops_spkt;
 
 static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,
-			   struct packet_type *pt, struct net_device *orig_dev)
+			   struct packet_type *pt)
 {
 	struct sock *sk;
 	struct sockaddr_pkt *spkt;
@@ -557,7 +557,7 @@ static inline unsigned int run_filter(const struct sk_buff *skb,
  */
 
 static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
-		      struct packet_type *pt, struct net_device *orig_dev)
+		      struct packet_type *pt)
 {
 	struct sock *sk;
 	struct sockaddr_ll *sll;
@@ -667,7 +667,7 @@ drop:
 }
 
 static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
-		       struct packet_type *pt, struct net_device *orig_dev)
+		       struct packet_type *pt)
 {
 	struct sock *sk;
 	struct packet_sock *po;
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 30cc676..2fb5bf2 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -372,8 +372,7 @@ static int send_reset_indications(struct sk_buff *rskb)
  * On error, returns non-zero and releases the skb.
  */
 static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pkttype,
-			struct net_device *orig_dev)
+			struct packet_type *pkttype)
 {
 	struct net *net = dev_net(dev);
 	struct phonethdr *ph;
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index b69092e..21c8fe4 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -100,7 +100,7 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
  */
 
 static int recv_msg(struct sk_buff *buf, struct net_device *dev,
-		    struct packet_type *pt, struct net_device *orig_dev)
+		    struct packet_type *pt)
 {
 	struct eth_bearer *eb_ptr = (struct eth_bearer *)pt->af_packet_priv;
 
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index 9005f6d..4b049ec 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -92,7 +92,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 }
 
 int x25_lapb_receive_frame(struct sk_buff *skb, struct net_device *dev,
-			   struct packet_type *ptype, struct net_device *orig_dev)
+			   struct packet_type *ptype)
 {
 	struct sk_buff *nskb;
 	struct x25_neigh *nb;
-- 
1.7.4

