From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce skb_set_link_header
Date: Mon, 04 Oct 2004 00:09:09 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4160BED5.6040207@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000105060809020209070501"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000105060809020209070501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are seven outstanding changesets in this tree.

Best Regards,

- Arnaldo

--------------000105060809020209070501
Content-Type: text/plain;
 name="skb_set_link_header.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skb_set_link_header.patch"

===================================================================


ChangeSet@1.2036, 2004-10-04 00:06:25-03:00, acme@conectiva.com.br
  [SKBUFF] introduce skb_set_link_header
  
  Abstracting setting the link layer sk_buff header, there are
  still some corner cases to handle, will work on those.
  
  This should make the code a bit more understandable and also
  removes a lot of direct accesses to skb->data.
  
  In the process found several places where foo_type_trans functions
  can be introduced, next patches will do that (AX.25, for instance).
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 arch/um/drivers/net_kern.c                |    2 +-
 drivers/ieee1394/eth1394.c                |    2 +-
 drivers/isdn/i4l/isdn_net.c               |    4 ++--
 drivers/isdn/i4l/isdn_ppp.c               |    2 +-
 drivers/media/dvb/dvb-core/dvb_net.c      |    2 +-
 drivers/message/fusion/mptlan.c           |    4 ++--
 drivers/net/appletalk/cops.c              |    2 +-
 drivers/net/appletalk/ltpc.c              |    2 +-
 drivers/net/arcnet/arc-rawmode.c          |    2 +-
 drivers/net/arcnet/rfc1051.c              |    2 +-
 drivers/net/arcnet/rfc1201.c              |    2 +-
 drivers/net/bonding/bond_3ad.c            |    4 ++--
 drivers/net/bonding/bond_alb.c            |    4 ++--
 drivers/net/hamradio/6pack.c              |    2 +-
 drivers/net/hamradio/baycom_epp.c         |    2 +-
 drivers/net/hamradio/bpqether.c           |    2 +-
 drivers/net/hamradio/dmascc.c             |    2 +-
 drivers/net/hamradio/hdlcdrv.c            |    2 +-
 drivers/net/hamradio/mkiss.c              |    2 +-
 drivers/net/hamradio/scc.c                |    2 +-
 drivers/net/hamradio/yam.c                |    2 +-
 drivers/net/irda/ali-ircc.c               |    2 +-
 drivers/net/irda/au1k_ir.c                |    2 +-
 drivers/net/irda/donauboe.c               |    2 +-
 drivers/net/irda/irda-usb.c               |    2 +-
 drivers/net/irda/nsc-ircc.c               |    2 +-
 drivers/net/irda/sa1100_ir.c              |    2 +-
 drivers/net/irda/smsc-ircc2.c             |    2 +-
 drivers/net/irda/stir4200.c               |    2 +-
 drivers/net/irda/via-ircc.c               |    8 ++++----
 drivers/net/irda/vlsi_ir.c                |    2 +-
 drivers/net/irda/w83977af_ir.c            |    2 +-
 drivers/net/plip.c                        |    2 +-
 drivers/net/ppp_generic.c                 |    2 +-
 drivers/net/sb1000.c                      |    2 +-
 drivers/net/slip.c                        |    2 +-
 drivers/net/tun.c                         |    2 +-
 drivers/net/wan/cosa.c                    |    2 +-
 drivers/net/wan/dlci.c                    |    2 +-
 drivers/net/wan/farsync.c                 |    2 +-
 drivers/net/wan/hostess_sv11.c            |    4 ++--
 drivers/net/wan/lmc/lmc_main.c            |    4 ++--
 drivers/net/wan/pc300_drv.c               |    2 +-
 drivers/net/wan/pc300_tty.c               |    2 +-
 drivers/net/wan/sdla_chdlc.c              |    6 +++---
 drivers/net/wan/sdla_fr.c                 |    6 +++---
 drivers/net/wan/sdla_ppp.c                |    4 ++--
 drivers/net/wan/sdla_x25.c                |   12 ++++++------
 drivers/net/wan/sealevel.c                |    2 +-
 drivers/net/wan/syncppp.c                 |    2 +-
 drivers/net/wan/wanpipe_multppp.c         |    6 +++---
 drivers/net/wireless/airo.c               |    4 ++--
 drivers/net/wireless/prism54/islpci_eth.c |    2 +-
 drivers/net/wireless/strip.c              |    2 +-
 drivers/s390/net/ctcmain.c                |    4 ++--
 drivers/s390/net/netiucv.c                |    4 ++--
 drivers/s390/net/qeth_main.c              |    6 +++---
 include/linux/hdlc.h                      |    2 +-
 include/linux/skbuff.h                    |    5 +++++
 net/802/fc.c                              |    2 +-
 net/802/fddi.c                            |    2 +-
 net/802/hippi.c                           |    2 +-
 net/802/tr.c                              |    2 +-
 net/atm/clip.c                            |    2 +-
 net/bluetooth/bnep/core.c                 |    2 +-
 net/bridge/br_device.c                    |    2 +-
 net/core/dev.c                            |    2 +-
 net/decnet/dn_route.c                     |    2 +-
 net/ethernet/eth.c                        |    4 ++--
 net/ipv4/ip_output.c                      |    2 +-
 net/ipv4/route.c                          |    2 +-
 net/ipv6/ip6_output.c                     |    2 +-
 net/ipv6/route.c                          |    2 +-
 net/irda/irlap_frame.c                    |    3 ++-
 net/irda/wrapper.c                        |    2 +-
 net/llc/llc_output.c                      |    6 ++++--
 net/llc/llc_sap.c                         |    2 +-
 net/wanrouter/wanmain.c                   |    2 +-
 78 files changed, 113 insertions(+), 105 deletions(-)


diff -Nru a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
--- a/arch/um/drivers/net_kern.c	2004-10-04 00:06:58 -03:00
+++ b/arch/um/drivers/net_kern.c	2004-10-04 00:06:58 -03:00
@@ -48,7 +48,7 @@
 
 	skb->dev = dev;
 	skb_put(skb, dev->mtu);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	pkt_len = (*lp->read)(lp->fd, &skb, lp);
 
 	if (pkt_len > 0) {
diff -Nru a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
--- a/drivers/ieee1394/eth1394.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/ieee1394/eth1394.c	2004-10-04 00:06:58 -03:00
@@ -848,7 +848,7 @@
 	struct eth1394hdr *eth;
 	unsigned char *rawp;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull (skb, ETH1394_HLEN);
 	eth = eth1394_hdr(skb);
 
diff -Nru a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
--- a/drivers/isdn/i4l/isdn_net.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/isdn/i4l/isdn_net.c	2004-10-04 00:06:58 -03:00
@@ -1367,7 +1367,7 @@
 	struct ethhdr *eth;
 	unsigned char *rawp;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 
@@ -1787,7 +1787,7 @@
 	}
 	skb->dev = ndev;
 	skb->pkt_type = PACKET_HOST;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 #ifdef ISDN_DEBUG_NET_DUMP
 	isdn_dumppkt("R:", skb->data, skb->len, 40);
 #endif
diff -Nru a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
--- a/drivers/isdn/i4l/isdn_ppp.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/isdn/i4l/isdn_ppp.c	2004-10-04 00:06:58 -03:00
@@ -1178,7 +1178,7 @@
 		mlp->huptimer = 0;
 #endif /* CONFIG_IPPP_FILTER */
 	skb->dev = dev;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	netif_rx(skb);
 	/* net_dev->local->stats.rx_packets++; done in isdn_net.c */
 	return;
diff -Nru a/drivers/media/dvb/dvb-core/dvb_net.c b/drivers/media/dvb/dvb-core/dvb_net.c
--- a/drivers/media/dvb/dvb-core/dvb_net.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/media/dvb/dvb-core/dvb_net.c	2004-10-04 00:06:58 -03:00
@@ -140,7 +140,7 @@
 	struct ethhdr *eth;
 	unsigned char *rawp;
 	
-	skb->mac.raw=skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb,dev->hard_header_len);
 	eth = eth_hdr(skb);
 	
diff -Nru a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
--- a/drivers/message/fusion/mptlan.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/message/fusion/mptlan.c	2004-10-04 00:06:58 -03:00
@@ -773,7 +773,7 @@
 	/* Set the mac.raw pointer, since this apparently isn't getting
 	 * done before we get the skb. Pull the data pointer past the mac data.
 	 */
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, 12);
 
         dma = pci_map_single(mpt_dev->pcidev, skb->data, skb->len,
@@ -1564,7 +1564,7 @@
 	struct mpt_lan_ohdr *fch = (struct mpt_lan_ohdr *)skb->data;
 	struct fcllc *fcllc;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, sizeof(struct mpt_lan_ohdr));
 
 	if (fch->dtype == htons(0xffff)) {
diff -Nru a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
--- a/drivers/net/appletalk/cops.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/appletalk/cops.c	2004-10-04 00:06:58 -03:00
@@ -854,7 +854,7 @@
                 return;
         }
 
-        skb->mac.raw    = skb->data;    /* Point to entire packet. */
+        skb_set_link_header(skb);    /* Point to entire packet. */
         skb_pull(skb,3);
         skb->h.raw      = skb->data;    /* Point to data (Skip header). */
 
diff -Nru a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
--- a/drivers/net/appletalk/ltpc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/appletalk/ltpc.c	2004-10-04 00:06:58 -03:00
@@ -770,7 +770,7 @@
 	skb->data[0] = dnode;
 	skb->data[1] = snode;
 	skb->data[2] = llaptype;
-	skb->mac.raw = skb->data;	/* save pointer to llap header */
+	skb_set_link_header(skb);	/* save pointer to llap header */
 	skb_pull(skb,3);
 
 	/* copy ddp(s,e)hdr + contents */
diff -Nru a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
--- a/drivers/net/arcnet/arc-rawmode.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/arcnet/arc-rawmode.c	2004-10-04 00:06:58 -03:00
@@ -109,7 +109,7 @@
 
 	pkt = (struct archdr *) skb->data;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, ARC_HDR_SIZE);
 
 	/* up to sizeof(pkt->soft) has already been copied from the card */
diff -Nru a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
--- a/drivers/net/arcnet/rfc1051.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/arcnet/rfc1051.c	2004-10-04 00:06:58 -03:00
@@ -91,7 +91,7 @@
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, hdr_size);
 
 	if (pkt->hard.dest == 0)
diff -Nru a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
--- a/drivers/net/arcnet/rfc1201.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/arcnet/rfc1201.c	2004-10-04 00:06:58 -03:00
@@ -94,7 +94,7 @@
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, hdr_size);
 
 	if (pkt->hard.dest == 0)
diff -Nru a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
--- a/drivers/net/bonding/bond_3ad.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/bonding/bond_3ad.c	2004-10-04 00:06:58 -03:00
@@ -917,7 +917,7 @@
 	}
 
 	skb->dev = slave->dev;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->nh.raw = skb->data + ETH_HLEN;
 	skb->protocol = PKT_TYPE_LACPDU;
 	skb->priority = TC_PRIO_CONTROL;
@@ -961,7 +961,7 @@
 	skb_reserve(skb, 16);
 
 	skb->dev = slave->dev;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->nh.raw = skb->data + ETH_HLEN;
 	skb->protocol = PKT_TYPE_LACPDU;
 
diff -Nru a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/bonding/bond_alb.c	2004-10-04 00:06:58 -03:00
@@ -906,7 +906,7 @@
 		data = skb_put(skb, size);
 		memcpy(data, &pkt, size);
 
-		skb->mac.raw = data;
+		skb_set_link_header(skb);
 		skb->nh.raw = data + ETH_HLEN;
 		skb->protocol = pkt.type;
 		skb->priority = TC_PRIO_CONTROL;
@@ -1284,7 +1284,7 @@
 	u8 *hash_start = NULL;
 	int res = 1;
 
-	skb->mac.raw = (unsigned char *)skb->data;
+	skb_set_link_header(skb);
 	eth_data = eth_hdr(skb);
 
 	/* make sure that the curr_active_slave and the slaves list do
diff -Nru a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
--- a/drivers/net/hamradio/6pack.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/6pack.c	2004-10-04 00:06:58 -03:00
@@ -429,7 +429,7 @@
 	*ptr++ = cmd;	/* KISS command */
 
 	memcpy(ptr, sp->cooked_buf + 1, count);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(ETH_P_AX25);
 	netif_rx(skb);
 	sp->dev->last_rx = jiffies;
diff -Nru a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
--- a/drivers/net/hamradio/baycom_epp.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/baycom_epp.c	2004-10-04 00:06:58 -03:00
@@ -624,7 +624,7 @@
 	*cp++ = 0; /* KISS kludge */
 	memcpy(cp, bc->hdlcrx.buf, pktlen - 1);
 	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	bc->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/bpqether.c	2004-10-04 00:06:58 -03:00
@@ -215,7 +215,7 @@
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = PACKET_HOST;
 
 	netif_rx(skb);
diff -Nru a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
--- a/drivers/net/hamradio/dmascc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/dmascc.c	2004-10-04 00:06:58 -03:00
@@ -1224,7 +1224,7 @@
       memcpy(&data[1], priv->rx_buf[i], cb);
       skb->dev = priv->dev;
       skb->protocol = ntohs(ETH_P_AX25);
-      skb->mac.raw = skb->data;
+      skb_set_link_header(skb);
       netif_rx(skb);
       priv->dev->last_rx = jiffies;
       priv->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
--- a/drivers/net/hamradio/hdlcdrv.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/hdlcdrv.c	2004-10-04 00:06:58 -03:00
@@ -179,7 +179,7 @@
 	*cp++ = 0; /* KISS kludge */
 	memcpy(cp, s->hdlcrx.buffer, pkt_len - 1);
 	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	netif_rx(skb);
 	dev->last_rx = jiffies;
 	s->stats.rx_packets++;
diff -Nru a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
--- a/drivers/net/hamradio/mkiss.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/mkiss.c	2004-10-04 00:06:58 -03:00
@@ -336,7 +336,7 @@
 	spin_lock_bh(&ax->buflock);
 	memcpy(skb_put(skb,count), ax->rbuff, count);
 	spin_unlock_bh(&ax->buflock);
-	skb->mac.raw  = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(ETH_P_AX25);
 	netif_rx(skb);
 	ax->dev->last_rx = jiffies;
diff -Nru a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
--- a/drivers/net/hamradio/scc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/scc.c	2004-10-04 00:06:58 -03:00
@@ -1632,7 +1632,7 @@
 
 	skb->dev      = scc->dev;
 	skb->protocol = htons(ETH_P_AX25);
-	skb->mac.raw  = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = PACKET_HOST;
 	
 	netif_rx(skb);
diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/hamradio/yam.c	2004-10-04 00:06:58 -03:00
@@ -527,7 +527,7 @@
 				*cp++ = 0;		/* KISS kludge */
 				memcpy(cp, yp->rx_buf, pkt_len - 1);
 				skb->protocol = htons(ETH_P_AX25);
-				skb->mac.raw = skb->data;
+				skb_set_link_header(skb);
 				netif_rx(skb);
 				dev->last_rx = jiffies;
 				++yp->stats.rx_packets;
diff -Nru a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
--- a/drivers/net/irda/ali-ircc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/ali-ircc.c	2004-10-04 00:06:58 -03:00
@@ -1910,7 +1910,7 @@
 			self->stats.rx_packets++;
 
 			skb->dev = self->netdev;
-			skb->mac.raw  = skb->data;
+			skb_set_link_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
 			self->netdev->last_rx = jiffies;
diff -Nru a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
--- a/drivers/net/irda/au1k_ir.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/au1k_ir.c	2004-10-04 00:06:58 -03:00
@@ -607,7 +607,7 @@
 				skb_put(skb, count-2);
 			memcpy(skb->data, (void *)pDB->vaddr, count-2);
 			skb->dev = dev;
-			skb->mac.raw = skb->data;
+			skb_set_link_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
 			prxd->count_0 = 0;
diff -Nru a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/donauboe.c	2004-10-04 00:06:58 -03:00
@@ -1298,7 +1298,7 @@
 
                       self->stats.rx_packets++;
                       skb->dev = self->netdev;
-                      skb->mac.raw = skb->data;
+                      skb_set_link_header(skb);
                       skb->protocol = htons (ETH_P_IRDA);
                     }
                   else
diff -Nru a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
--- a/drivers/net/irda/irda-usb.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/irda-usb.c	2004-10-04 00:06:58 -03:00
@@ -830,7 +830,7 @@
 
 	/* Ask the networking layer to queue the packet for the IrDA stack */
 	dataskb->dev = self->netdev;
-	dataskb->mac.raw  = dataskb->data;
+	skb_set_link_header(dataskb);
 	dataskb->protocol = htons(ETH_P_IRDA);
 	netif_rx(dataskb);
 
diff -Nru a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/nsc-ircc.c	2004-10-04 00:06:58 -03:00
@@ -1732,7 +1732,7 @@
 			self->stats.rx_packets++;
 
 			skb->dev = self->netdev;
-			skb->mac.raw  = skb->data;
+			skb_set_link_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
 			self->netdev->last_rx = jiffies;
diff -Nru a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
--- a/drivers/net/irda/sa1100_ir.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/sa1100_ir.c	2004-10-04 00:06:58 -03:00
@@ -570,7 +570,7 @@
 
 		skb_put(skb, len);
 		skb->dev = dev;
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->protocol = htons(ETH_P_IRDA);
 		si->stats.rx_packets++;
 		si->stats.rx_bytes += len;
diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/smsc-ircc2.c	2004-10-04 00:06:58 -03:00
@@ -1344,7 +1344,7 @@
 	self->stats.rx_bytes += len;
 
 	skb->dev = self->netdev;
-	skb->mac.raw  = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
 	netif_rx(skb);
 }
diff -Nru a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
--- a/drivers/net/irda/stir4200.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/stir4200.c	2004-10-04 00:06:58 -03:00
@@ -368,7 +368,7 @@
 
 	skb_put(skb, len);
 
-	skb->mac.raw  = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
 	skb->dev = stir->netdev;
 
diff -Nru a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
--- a/drivers/net/irda/via-ircc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/via-ircc.c	2004-10-04 00:06:58 -03:00
@@ -1079,7 +1079,7 @@
 		self->stats.rx_bytes += len;
 		self->stats.rx_packets++;
 		skb->dev = self->netdev;
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->protocol = htons(ETH_P_IRDA);
 		netif_rx(skb);
 		return TRUE;
@@ -1163,7 +1163,7 @@
 		self->stats.rx_bytes += len;
 		self->stats.rx_packets++;
 		skb->dev = self->netdev;
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->protocol = htons(ETH_P_IRDA);
 		netif_rx(skb);
 
@@ -1205,7 +1205,7 @@
 	self->stats.rx_bytes += len;
 	self->stats.rx_packets++;
 	skb->dev = self->netdev;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
 	netif_rx(skb);
 	if (st_fifo->len < (MAX_RX_WINDOW + 2)) {
@@ -1275,7 +1275,7 @@
 			self->stats.rx_bytes += len;
 			self->stats.rx_packets++;
 			skb->dev = self->netdev;
-			skb->mac.raw = skb->data;
+			skb_set_link_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
 		}		//while
diff -Nru a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
--- a/drivers/net/irda/vlsi_ir.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/vlsi_ir.c	2004-10-04 00:06:58 -03:00
@@ -596,7 +596,7 @@
 	rd->skb = NULL;
 	skb->dev = ndev;
 	memcpy(skb_put(skb,len), rd->buf, len);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	if (in_interrupt())
 		netif_rx(skb);
 	else
diff -Nru a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
--- a/drivers/net/irda/w83977af_ir.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/irda/w83977af_ir.c	2004-10-04 00:06:58 -03:00
@@ -920,7 +920,7 @@
 			self->stats.rx_packets++;
 			
 			skb->dev = self->netdev;
-			skb->mac.raw  = skb->data;
+			skb_set_link_header(skb);
 			skb->protocol = htons(ETH_P_IRDA);
 			netif_rx(skb);
 			self->netdev->last_rx = jiffies;
diff -Nru a/drivers/net/plip.c b/drivers/net/plip.c
--- a/drivers/net/plip.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/plip.c	2004-10-04 00:06:58 -03:00
@@ -545,7 +545,7 @@
 	struct ethhdr *eth;
 	unsigned char *rawp;
 	
-	skb->mac.raw=skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb,dev->hard_header_len);
 	eth = eth_hdr(skb);
 	
diff -Nru a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
--- a/drivers/net/ppp_generic.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/ppp_generic.c	2004-10-04 00:06:58 -03:00
@@ -1594,7 +1594,7 @@
 			skb_pull(skb, 2);	/* chop off protocol */
 			skb->dev = ppp->dev;
 			skb->protocol = htons(npindex_to_ethertype[npi]);
-			skb->mac.raw = skb->data;
+			skb_set_link_header(skb);
 			skb->input_dev = ppp->dev;
 			netif_rx(skb);
 			ppp->dev->last_rx = jiffies;
diff -Nru a/drivers/net/sb1000.c b/drivers/net/sb1000.c
--- a/drivers/net/sb1000.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/sb1000.c	2004-10-04 00:06:58 -03:00
@@ -842,7 +842,7 @@
 			goto dropped_frame;
 		}
 		skb->dev = dev;
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->protocol = (unsigned short) buffer[NewDatagramHeaderSkip + 16];
 		insw(ioaddr, skb_put(skb, NewDatagramDataSize),
 			NewDatagramDataSize / 2);
diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/slip.c	2004-10-04 00:06:58 -03:00
@@ -374,7 +374,7 @@
 	}
 	skb->dev = sl->dev;
 	memcpy(skb_put(skb,count), sl->rbuff, count);
-	skb->mac.raw=skb->data;
+	skb_set_link_header(skb);
 	skb->protocol=htons(ETH_P_IP);
 	netif_rx(skb);
 	sl->dev->last_rx = jiffies;
diff -Nru a/drivers/net/tun.c b/drivers/net/tun.c
--- a/drivers/net/tun.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/tun.c	2004-10-04 00:06:58 -03:00
@@ -196,7 +196,7 @@
 	skb->dev = tun->dev;
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->protocol = pi.proto;
 		break;
 	case TUN_TAP_DEV:
diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/cosa.c	2004-10-04 00:06:58 -03:00
@@ -787,7 +787,7 @@
 	}
 	chan->rx_skb->protocol = htons(ETH_P_WAN_PPP);
 	chan->rx_skb->dev = chan->pppdev.dev;
-	chan->rx_skb->mac.raw = chan->rx_skb->data;
+	skb_set_link_header(chan->rx_skb);
 	chan->stats.rx_packets++;
 	chan->stats.rx_bytes += chan->cosa->rxsize;
 	netif_rx(chan->rx_skb);
diff -Nru a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
--- a/drivers/net/wan/dlci.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/dlci.c	2004-10-04 00:06:58 -03:00
@@ -177,7 +177,7 @@
 	if (process)
 	{
 		/* we've set up the protocol, so discard the header */
-		skb->mac.raw = skb->data; 
+		skb_set_link_header(skb); 
 		skb_pull(skb, header);
 		dlp->stats.rx_bytes += skb->len;
 		netif_rx(skb);
diff -Nru a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
--- a/drivers/net/wan/farsync.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/farsync.c	2004-10-04 00:06:58 -03:00
@@ -864,7 +864,7 @@
 					 struct net_device *dev)
 {
 	skb->dev = dev;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = PACKET_HOST;
 	return htons(ETH_P_CUST);
 }
diff -Nru a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
--- a/drivers/net/wan/hostess_sv11.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/hostess_sv11.c	2004-10-04 00:06:58 -03:00
@@ -57,8 +57,8 @@
 {
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
 	skb_trim(skb, skb->len-2);
-	skb->protocol=__constant_htons(ETH_P_WAN_PPP);
-	skb->mac.raw=skb->data;
+	skb->protocol = htons(ETH_P_WAN_PPP);
+	skb_set_link_header(skb);
 	skb->dev=c->netdevice;
 	/*
 	 *	Send it to the PPP layer. We don't have time to process
diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
--- a/drivers/net/wan/lmc/lmc_main.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/lmc/lmc_main.c	2004-10-04 00:06:58 -03:00
@@ -1673,7 +1673,7 @@
             skb_put (skb, len);
             skb->protocol = lmc_proto_type(sc, skb);
             skb->protocol = htons(ETH_P_WAN_PPP);
-            skb->mac.raw = skb->data;
+            skb_set_link_header(skb);
 //            skb->nh.raw = skb->data;
             skb->dev = dev;
             lmc_proto_netif(sc, skb);
@@ -1711,7 +1711,7 @@
             memcpy(skb_put(nsb, len), skb->data, len);
             
             nsb->protocol = lmc_proto_type(sc, skb);
-            nsb->mac.raw = nsb->data;
+            skb_set_link_header(nsb);
 //            nsb->nh.raw = nsb->data;
             nsb->dev = dev;
             lmc_proto_netif(sc, nsb);
diff -Nru a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
--- a/drivers/net/wan/pc300_drv.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/pc300_drv.c	2004-10-04 00:06:58 -03:00
@@ -1754,7 +1754,7 @@
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_CUST);
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = PACKET_HOST;
 	skb->len = 10 + skb_main->len;
 
diff -Nru a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
--- a/drivers/net/wan/pc300_tty.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/pc300_tty.c	2004-10-04 00:06:58 -03:00
@@ -1026,7 +1026,7 @@
 	skb_put (skb, 10 + len); 
 	skb->dev = dev->dev; 
 	skb->protocol = htons(ETH_P_CUST); 
-	skb->mac.raw = skb->data; 
+	skb_set_link_header(skb); 
 	skb->pkt_type = PACKET_HOST; 
 	skb->len = 10 + len; 
 
diff -Nru a/drivers/net/wan/sdla_chdlc.c b/drivers/net/wan/sdla_chdlc.c
--- a/drivers/net/wan/sdla_chdlc.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/sdla_chdlc.c	2004-10-04 00:06:58 -03:00
@@ -2037,7 +2037,7 @@
      		api_rx_hdr->time_stamp = rxbuf->time_stamp;
 
                 skb->protocol = htons(PVC_PROT);
-     		skb->mac.raw  = skb->data;
+     		skb_set_link_header(skb);
 		skb->dev      = dev;
                	skb->pkt_type = WAN_PACKET_DATA;
 
@@ -2054,7 +2054,7 @@
                	/* Pass it up the protocol stack */
 	
                 skb->dev = dev;
-                skb->mac.raw  = skb->data;
+                skb_set_link_header(skb);
                 netif_rx(skb);
                 dev->last_rx = jiffies;
 	}
@@ -3058,7 +3058,7 @@
             		/* Decapsulate pkt and pass it up the protocol stack */
 	    		new_skb->protocol = htons(ETH_P_IP);
             		new_skb->dev = dev;
-	    		new_skb->mac.raw  = new_skb->data;
+	    		skb_set_link_header(new_skb);
 	
 			netif_rx(new_skb);
 			dev->last_rx = jiffies;
diff -Nru a/drivers/net/wan/sdla_fr.c b/drivers/net/wan/sdla_fr.c
--- a/drivers/net/wan/sdla_fr.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/sdla_fr.c	2004-10-04 00:06:58 -03:00
@@ -2097,7 +2097,7 @@
 		api_rx_hdr->time_stamp = frbuf->tmstamp;
 
 		skb->protocol = htons(ETH_P_IP);
-		skb->mac.raw  = skb->data;
+		skb_set_link_header(skb);
 		skb->dev      = dev;
 		skb->pkt_type = WAN_PACKET_DATA;
 
@@ -2170,7 +2170,7 @@
 				++card->wandev.stats.rx_errors;
 				goto rx_done;	
 			}
-			skb->mac.raw = skb->data;
+			skb_set_link_header(skb);
 		} 
 		
 
@@ -3901,7 +3901,7 @@
 				UDP_PIPE_mgmt_passed_to_stack ++;
 			new_skb->dev = dev;
 			new_skb->protocol = htons(ETH_P_IP);
-			new_skb->mac.raw = new_skb->data;
+			skb_set_link_header(new_skb);
 			netif_rx(new_skb);
             	
 		} else {
diff -Nru a/drivers/net/wan/sdla_ppp.c b/drivers/net/wan/sdla_ppp.c
--- a/drivers/net/wan/sdla_ppp.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/sdla_ppp.c	2004-10-04 00:06:58 -03:00
@@ -1756,7 +1756,7 @@
 			} else {
 				/* Pass data up the protocol stack */
 	    			skb->dev = dev;
-				skb->mac.raw  = skb->data;
+				skb_set_link_header(skb);
 
 			    	++card->wandev.stats.rx_packets;
 				card->wandev.stats.rx_bytes += skb->len;
@@ -2756,7 +2756,7 @@
 			   stack */
 	    		new_skb->protocol = htons(ETH_P_IP);
             		new_skb->dev = dev;
-	    		new_skb->mac.raw  = new_skb->data;
+	    		skb_set_link_header(new_skb);
 			netif_rx(new_skb);
 			dev->last_rx = jiffies;
 		
diff -Nru a/drivers/net/wan/sdla_x25.c b/drivers/net/wan/sdla_x25.c
--- a/drivers/net/wan/sdla_x25.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/sdla_x25.c	2004-10-04 00:06:58 -03:00
@@ -1766,7 +1766,7 @@
 				++chan->rx_intr_stat.rx_intr_bfr_not_passed_to_stack;
 			}
 		}else{
-			skb->mac.raw = skb->data;
+			skb_set_link_header(skb);
 			chan->ifstats.rx_bytes += skb->len;
 			++chan->ifstats.rx_packets;
 			++chan->rx_intr_stat.rx_intr_bfr_passed_to_stack;
@@ -1858,7 +1858,7 @@
 	new_skb->dev = dev;
 
 	if (chan->common.usedby == API){
-		new_skb->mac.raw = new_skb->data;
+		skb_set_link_header(new_skb);
 		new_skb->protocol = htons(X25_PROT);
 		new_skb->pkt_type = WAN_PACKET_DATA;
 	}else{
@@ -4658,7 +4658,7 @@
 
 	memcpy(skb_put(skb,len),&mbox->cmd,len);
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(X25_PROT);
 	skb->pkt_type = WAN_PACKET_ASYNC;
 
@@ -4716,7 +4716,7 @@
 
 	memcpy(skb_put(skb,len),&mbox->cmd.command,len);
 	
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = WAN_PACKET_CMD;
 			
 	chan->common.func(skb,dev,chan->common.sk);
@@ -4826,7 +4826,7 @@
 		memcpy(api_hdr->data,mbox->data,mbox->cmd.length);
 	}
 	
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = WAN_PACKET_ERR;
 			
 	if (chan->common.func(skb,dev,chan->common.sk) < 0){
@@ -5193,7 +5193,7 @@
 			else 
 				new_skb->protocol = htons(ETH_P_IP);
 	
-                        new_skb->mac.raw = new_skb->data;
+                        skb_set_link_header(new_skb);
 
 			netif_rx(new_skb);
 			++chan->pipe_mgmt_stat.UDP_PIPE_mgmt_passed_to_stack;
diff -Nru a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
--- a/drivers/net/wan/sealevel.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/sealevel.c	2004-10-04 00:06:58 -03:00
@@ -60,7 +60,7 @@
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
 	skb_trim(skb, skb->len-2);
 	skb->protocol=htons(ETH_P_WAN_PPP);
-	skb->mac.raw=skb->data;
+	skb_set_link_header(skb);
 	skb->dev=c->netdevice;
 	/*
 	 *	Send it to the PPP layer. We don't have time to process
diff -Nru a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
--- a/drivers/net/wan/syncppp.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/syncppp.c	2004-10-04 00:06:58 -03:00
@@ -228,7 +228,7 @@
 	unsigned long flags;
 
 	skb->dev=dev;
-	skb->mac.raw=skb->data;
+	skb_set_link_header(skb);
 
 	if (dev->flags & IFF_RUNNING)
 	{
diff -Nru a/drivers/net/wan/wanpipe_multppp.c b/drivers/net/wan/wanpipe_multppp.c
--- a/drivers/net/wan/wanpipe_multppp.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wan/wanpipe_multppp.c	2004-10-04 00:06:58 -03:00
@@ -1455,7 +1455,7 @@
 	}else{
                	/* Pass it up the protocol stack */
                 skb->dev = dev;
-                skb->mac.raw  = skb->data;
+                skb_set_link_header(skb);
                 netif_rx(skb);
                 dev->last_rx = jiffies;
 	}
@@ -2056,7 +2056,7 @@
             		/* Decapsulate pkt and pass it up the protocol stack */
 	    		new_skb->protocol = htons(ETH_P_IP);
             		new_skb->dev = dev;
-	    		new_skb->mac.raw  = new_skb->data;
+	    		skb_set_link_header(new_skb);
 	
 			netif_rx(new_skb);
 			dev->last_rx = jiffies;
@@ -2344,7 +2344,7 @@
 		/* Decapsulate pkt and pass it up the protocol stack */
 		new_skb->protocol = htons(ETH_P_WAN_PPP);
 		new_skb->dev = dev;
-		new_skb->mac.raw  = new_skb->data;
+		skb_set_link_header(new_skb);
 
 		netif_rx(new_skb);
 		dev->last_rx = jiffies;
diff -Nru a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wireless/airo.c	2004-10-04 00:06:58 -03:00
@@ -3255,7 +3255,7 @@
 			OUT4500( apriv, EVACK, EV_RX);
 
 			if (test_bit(FLAG_802_11, &apriv->flags)) {
-				skb->mac.raw = skb->data;
+				skb_set_link_header(skb);
 				skb->pkt_type = PACKET_OTHERHOST;
 				skb->dev = apriv->wifidev;
 				skb->protocol = htons(ETH_P_802_2);
@@ -3595,7 +3595,7 @@
 		wireless_spy_update(ai->dev, sa, &wstats);
 	}
 #endif /* IW_WIRELESS_SPY */
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->dev = ai->wifidev;
 	skb->protocol = htons(ETH_P_802_2);
diff -Nru a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
--- a/drivers/net/wireless/prism54/islpci_eth.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wireless/prism54/islpci_eth.c	2004-10-04 00:06:58 -03:00
@@ -312,7 +312,7 @@
 		skb_pull(*skb, sizeof (struct rfmon_header));
 
 	(*skb)->protocol = htons(ETH_P_802_2);
-	(*skb)->mac.raw = (*skb)->data;
+	skb_set_link_header(*skb);
 	(*skb)->pkt_type = PACKET_OTHERHOST;
 
 	return 0;
diff -Nru a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
--- a/drivers/net/wireless/strip.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/net/wireless/strip.c	2004-10-04 00:06:58 -03:00
@@ -2020,7 +2020,7 @@
 		       packetlen);
 		skb->dev = get_strip_dev(strip_info);
 		skb->protocol = header->protocol;
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 
 		/* Having put a fake header on the front of the sk_buff for the */
 		/* benefit of tools like tcpdump, skb_pull now 'consumes' that  */
diff -Nru a/drivers/s390/net/ctcmain.c b/drivers/s390/net/ctcmain.c
--- a/drivers/s390/net/ctcmain.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/s390/net/ctcmain.c	2004-10-04 00:06:58 -03:00
@@ -699,7 +699,7 @@
 			return;
 		}
 		skb_put(pskb, header->length);
-		pskb->mac.raw = pskb->data;
+		skb_set_link_header(pskb);
 		len -= header->length;
 		skb = dev_alloc_skb(pskb->len);
 		if (!skb) {
@@ -717,7 +717,7 @@
 			return;
 		}
 		memcpy(skb_put(skb, pskb->len), pskb->data, pskb->len);
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->dev = pskb->dev;
 		skb->protocol = pskb->protocol;
 		pskb->ip_summed = CHECKSUM_UNNECESSARY;
diff -Nru a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
--- a/drivers/s390/net/netiucv.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/s390/net/netiucv.c	2004-10-04 00:06:58 -03:00
@@ -565,7 +565,7 @@
 			return;
 		}
 		skb_put(pskb, header->next);
-		pskb->mac.raw = pskb->data;
+		skb_set_link_header(pskb);
 		skb = dev_alloc_skb(pskb->len);
 		if (!skb) {
 			PRINT_WARN("%s Out of memory in netiucv_unpack_skb\n",
@@ -576,7 +576,7 @@
 			return;
 		}
 		memcpy(skb_put(skb, pskb->len), pskb->data, pskb->len);
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 		skb->dev = pskb->dev;
 		skb->protocol = pskb->protocol;
 		pskb->ip_summed = CHECKSUM_UNNECESSARY;
diff -Nru a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
--- a/drivers/s390/net/qeth_main.c	2004-10-04 00:06:58 -03:00
+++ b/drivers/s390/net/qeth_main.c	2004-10-04 00:06:58 -03:00
@@ -2146,7 +2146,7 @@
 	 	return tr_type_trans(skb,dev);
 #endif /* CONFIG_TR */
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, ETH_ALEN * 2 + sizeof (short));
 	eth = eth_hdr(skb);
 
@@ -2175,7 +2175,7 @@
 	QETH_DBF_TEXT(trace,5,"skbfake");
 	skb->mac.raw = skb->data - QETH_FAKE_LL_LEN;
 	/* this is a fake ethernet header */
-	fake_hdr = (struct ethhdr *) skb->mac.raw;
+	fake_hdr = eth_hdr(skb);
 
 	/* the destination MAC address */
 	switch (skb->pkt_type){
@@ -2262,7 +2262,7 @@
 	if (card->options.fake_ll)
 		qeth_rebuild_skb_fake_ll(card, skb, hdr);
 	else
-		skb->mac.raw = skb->data;
+		skb_set_link_header(skb);
 	skb->ip_summed = card->options.checksum_type;
 	if (card->options.checksum_type == HW_CHECKSUMMING){
 		if ( (hdr->ext_flags &
diff -Nru a/include/linux/hdlc.h b/include/linux/hdlc.h
--- a/include/linux/hdlc.h	2004-10-04 00:06:58 -03:00
+++ b/include/linux/hdlc.h	2004-10-04 00:06:58 -03:00
@@ -245,7 +245,7 @@
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 
-	skb->mac.raw  = skb->data;
+	skb_set_link_header(skb);
 	skb->dev      = dev;
 
 	if (hdlc->proto.type_trans)
diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	2004-10-04 00:06:58 -03:00
+++ b/include/linux/skbuff.h	2004-10-04 00:06:58 -03:00
@@ -290,6 +290,11 @@
 
 #include <asm/system.h>
 
+static inline void skb_set_link_header(struct sk_buff *skb)
+{
+	skb->mac.raw = skb->data;
+}
+
 extern void	       __kfree_skb(struct sk_buff *skb);
 extern struct sk_buff *alloc_skb(unsigned int size, int priority);
 extern void	       kfree_skbmem(struct sk_buff *skb);
diff -Nru a/net/802/fc.c b/net/802/fc.c
--- a/net/802/fc.c	2004-10-04 00:06:58 -03:00
+++ b/net/802/fc.c	2004-10-04 00:06:58 -03:00
@@ -102,7 +102,7 @@
 	struct fch_hdr *fch = (struct fch_hdr *)skb->data;
 	struct fcllc *fcllc;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	fcllc = (struct fcllc *)(skb->data + sizeof (struct fch_hdr) + 2);
 	skb_pull(skb, sizeof (struct fch_hdr) + 2);
 
diff -Nru a/net/802/fddi.c b/net/802/fddi.c
--- a/net/802/fddi.c	2004-10-04 00:06:58 -03:00
+++ b/net/802/fddi.c	2004-10-04 00:06:58 -03:00
@@ -131,7 +131,7 @@
 	 * to start of packet data.  Assume 802.2 SNAP frames for now.
 	 */
 
-	skb->mac.raw = skb->data;	/* point to frame control (FC) */
+	skb_set_link_header(skb);	/* point to frame control (FC) */
 	
 	if(fddi->hdr.llc_8022_1.dsap==0xe0)
 	{
diff -Nru a/net/802/hippi.c b/net/802/hippi.c
--- a/net/802/hippi.c	2004-10-04 00:06:58 -03:00
+++ b/net/802/hippi.c	2004-10-04 00:06:58 -03:00
@@ -143,7 +143,7 @@
 	 * This is actually wrong ... question is if we really should
 	 * set the raw address here.
 	 */
-	 skb->mac.raw = skb->data;
+	 skb_set_link_header(skb);
 	 skb_pull(skb, HIPPI_HLEN);
 
 	/*
diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	2004-10-04 00:06:58 -03:00
+++ b/net/802/tr.c	2004-10-04 00:06:58 -03:00
@@ -193,7 +193,7 @@
 	struct trllc *trllc;
 	unsigned riflen=0;
 	
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	
        	if(trh->saddr[0] & TR_RII)
 		riflen = (ntohs(trh->rcf) & TR_RCF_LEN_MASK) >> 8;
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	2004-10-04 00:06:58 -03:00
+++ b/net/atm/clip.c	2004-10-04 00:06:58 -03:00
@@ -211,7 +211,7 @@
 		return;
 	}
 	ATM_SKB(skb)->vcc = vcc;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	if (!clip_vcc->encap || skb->len < RFC1483LLC_LEN || memcmp(skb->data,
 	    llc_oui,sizeof(llc_oui))) skb->protocol = htons(ETH_P_IP);
 	else {
diff -Nru a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
--- a/net/bluetooth/bnep/core.c	2004-10-04 00:06:58 -03:00
+++ b/net/bluetooth/bnep/core.c	2004-10-04 00:06:58 -03:00
@@ -326,7 +326,7 @@
 		return 0;
 	}
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 
 	/* Verify and pull out header */
 	if (!skb_pull(skb, __bnep_rx_hlen[type & BNEP_TYPE_MASK]))
diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	2004-10-04 00:06:58 -03:00
+++ b/net/bridge/br_device.c	2004-10-04 00:06:58 -03:00
@@ -37,7 +37,7 @@
 	br->statistics.tx_packets++;
 	br->statistics.tx_bytes += skb->len;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
 	rcu_read_lock();
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-10-04 00:06:58 -03:00
+++ b/net/core/dev.c	2004-10-04 00:06:58 -03:00
@@ -1083,7 +1083,7 @@
 			   set by sender, so that the second statement is
 			   just protection against buggy protocols.
 			 */
-			skb2->mac.raw = skb2->data;
+			skb_set_link_header(skb2);
 
 			if (skb2->nh.raw < skb2->data ||
 			    skb2->nh.raw > skb2->tail) {
diff -Nru a/net/decnet/dn_route.c b/net/decnet/dn_route.c
--- a/net/decnet/dn_route.c	2004-10-04 00:06:58 -03:00
+++ b/net/decnet/dn_route.c	2004-10-04 00:06:58 -03:00
@@ -1555,7 +1555,7 @@
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
 		return -ENOBUFS;
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	cb = DN_SKB_CB(skb);
 
 	if (rta[RTA_SRC-1])
diff -Nru a/net/ethernet/eth.c b/net/ethernet/eth.c
--- a/net/ethernet/eth.c	2004-10-04 00:06:58 -03:00
+++ b/net/ethernet/eth.c	2004-10-04 00:06:58 -03:00
@@ -161,8 +161,8 @@
 	struct ethhdr *eth;
 	unsigned char *rawp;
 	
-	skb->mac.raw=skb->data;
-	skb_pull(skb,ETH_HLEN);
+	skb_set_link_header(skb);
+	skb_pull(skb, ETH_HLEN);
 	eth = eth_hdr(skb);
 	skb->input_dev = dev;
 	
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2004-10-04 00:06:58 -03:00
+++ b/net/ipv4/ip_output.c	2004-10-04 00:06:58 -03:00
@@ -102,7 +102,7 @@
 /* dev_loopback_xmit for use with netfilter. */
 static int ip_dev_loopback_xmit(struct sk_buff *newskb)
 {
-	newskb->mac.raw = newskb->data;
+	skb_set_link_header(newskb);
 	__skb_pull(newskb, newskb->nh.raw - newskb->data);
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2004-10-04 00:06:58 -03:00
+++ b/net/ipv4/route.c	2004-10-04 00:06:58 -03:00
@@ -2351,7 +2351,7 @@
 	/* Reserve room for dummy headers, this skb can pass
 	   through good chunk of routing engine.
 	 */
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
 
 	if (rta[RTA_SRC - 1])
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-10-04 00:06:58 -03:00
+++ b/net/ipv6/ip6_output.c	2004-10-04 00:06:58 -03:00
@@ -97,7 +97,7 @@
 /* dev_loopback_xmit for use with netfilter. */
 static int ip6_dev_loopback_xmit(struct sk_buff *newskb)
 {
-	newskb->mac.raw = newskb->data;
+	skb_set_link_header(newskb);
 	__skb_pull(newskb, newskb->nh.raw - newskb->data);
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-04 00:06:58 -03:00
+++ b/net/ipv6/route.c	2004-10-04 00:06:58 -03:00
@@ -1763,7 +1763,7 @@
 	/* Reserve room for dummy headers, this skb can pass
 	   through good chunk of routing engine.
 	 */
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
 	memset(&fl, 0, sizeof(fl));
diff -Nru a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
--- a/net/irda/irlap_frame.c	2004-10-04 00:06:58 -03:00
+++ b/net/irda/irlap_frame.c	2004-10-04 00:06:58 -03:00
@@ -90,7 +90,8 @@
 {
 	/* Some common init stuff */
 	skb->dev = self->netdev;
-	skb->h.raw = skb->nh.raw = skb->mac.raw = skb->data;
+	skb->h.raw = skb->nh.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->protocol = htons(ETH_P_IRDA);
 	skb->priority = TC_PRIO_BESTEFFORT;
 
diff -Nru a/net/irda/wrapper.c b/net/irda/wrapper.c
--- a/net/irda/wrapper.c	2004-10-04 00:06:58 -03:00
+++ b/net/irda/wrapper.c	2004-10-04 00:06:58 -03:00
@@ -252,7 +252,7 @@
 
 	/* Feed it to IrLAP layer */
 	dataskb->dev = dev;
-	dataskb->mac.raw  = dataskb->data;
+	skb_set_link_header(dataskb);
 	dataskb->protocol = htons(ETH_P_IRDA);
 
 	netif_rx(dataskb);
diff -Nru a/net/llc/llc_output.c b/net/llc/llc_output.c
--- a/net/llc/llc_output.c	2004-10-04 00:06:58 -03:00
+++ b/net/llc/llc_output.c	2004-10-04 00:06:58 -03:00
@@ -40,7 +40,8 @@
 		struct net_device *dev = skb->dev;
 		struct trh_hdr *trh;
 		
-		skb->mac.raw = skb_push(skb, sizeof(*trh));
+		skb_push(skb, sizeof(*trh));
+		skb_set_link_header(skb);
 		trh = tr_hdr(skb);
 		trh->ac = AC;
 		trh->fc = LLC_FRAME;
@@ -60,7 +61,8 @@
 		unsigned short len = skb->len;
 		struct ethhdr *eth;
 
-		skb->mac.raw = skb_push(skb, sizeof(*eth));
+		skb_push(skb, sizeof(*eth));
+		skb_set_link_header(skb);
 		eth = eth_hdr(skb);
 		eth->h_proto = htons(len);
 		memcpy(eth->h_dest, da, ETH_ALEN);
diff -Nru a/net/llc/llc_sap.c b/net/llc/llc_sap.c
--- a/net/llc/llc_sap.c	2004-10-04 00:06:58 -03:00
+++ b/net/llc/llc_sap.c	2004-10-04 00:06:58 -03:00
@@ -35,11 +35,11 @@
 	struct sk_buff *skb = alloc_skb(128, GFP_ATOMIC);
 
 	if (skb) {
+		skb_set_link_header(skb);
 		skb_reserve(skb, 50);
 		skb->nh.raw   = skb->h.raw = skb->data;
 		skb->protocol = htons(ETH_P_802_2);
 		skb->dev      = dev_base->next;
-		skb->mac.raw  = skb->head;
 	}
 	return skb;
 }
diff -Nru a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
--- a/net/wanrouter/wanmain.c	2004-10-04 00:06:58 -03:00
+++ b/net/wanrouter/wanmain.c	2004-10-04 00:06:58 -03:00
@@ -394,7 +394,7 @@
 	skb->protocol = ethertype;
 	skb->pkt_type = PACKET_HOST;	/*	Physically point to point */
 	skb_pull(skb, cnt);
-	skb->mac.raw  = skb->data;
+	skb_set_link_header(skb);
 	return ethertype;
 }
 


--------------000105060809020209070501--
