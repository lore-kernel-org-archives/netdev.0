From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] do some more skb_set_link_header conversions
Date: Mon, 04 Oct 2004 00:32:22 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4160C446.2030708@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090804030806000307000006"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090804030806000307000006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are eight outstanding changesets in this tree.

- Arnaldo

--------------090804030806000307000006
Content-Type: text/plain;
 name="skb_set_link_header2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skb_set_link_header2.patch"

===================================================================


ChangeSet@1.2037, 2004-10-04 00:28:19-03:00, acme@conectiva.com.br
  [SKBUFF] do some more skb_set_link_header conversions
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/net/wan/cycx_x25.c |    2 +-
 include/net/x25device.h    |    2 +-
 net/802/fddi.c             |    2 +-
 net/bridge/br_stp_bpdu.c   |    3 ++-
 4 files changed, 5 insertions(+), 4 deletions(-)


diff -Nru a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
--- a/drivers/net/wan/cycx_x25.c	2004-10-04 00:30:13 -03:00
+++ b/drivers/net/wan/cycx_x25.c	2004-10-04 00:30:13 -03:00
@@ -837,7 +837,7 @@
 	++chan->ifstats.rx_packets;
 	chan->ifstats.rx_bytes += pktlen;
 
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	netif_rx(skb);
 	dev->last_rx = jiffies;		/* timestamp */
 }
diff -Nru a/include/net/x25device.h b/include/net/x25device.h
--- a/include/net/x25device.h	2004-10-04 00:30:13 -03:00
+++ b/include/net/x25device.h	2004-10-04 00:30:13 -03:00
@@ -8,7 +8,7 @@
 static inline unsigned short x25_type_trans(struct sk_buff *skb,
 					    struct net_device *dev)
 {
-	skb->mac.raw = skb->data;
+	skb_set_link_header(skb);
 	skb->input_dev = skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 	
diff -Nru a/net/802/fddi.c b/net/802/fddi.c
--- a/net/802/fddi.c	2004-10-04 00:30:13 -03:00
+++ b/net/802/fddi.c	2004-10-04 00:30:13 -03:00
@@ -127,7 +127,7 @@
 	unsigned short type;
 	
 	/*
-	 * Set mac.raw field to point to FC byte, set data field to point
+	 * Set link header field to point to FC byte, set data field to point
 	 * to start of packet data.  Assume 802.2 SNAP frames for now.
 	 */
 
diff -Nru a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
--- a/net/bridge/br_stp_bpdu.c	2004-10-04 00:30:13 -03:00
+++ b/net/bridge/br_stp_bpdu.c	2004-10-04 00:30:13 -03:00
@@ -44,7 +44,8 @@
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_802_2);
-	skb->mac.raw = skb_put(skb, size);
+	skb_set_link_header(skb);
+	skb_put(skb, size);
 	memcpy(skb->mac.raw, bridge_ula, ETH_ALEN);
 	memcpy(skb->mac.raw+ETH_ALEN, dev->dev_addr, ETH_ALEN);
 	skb->mac.raw[2*ETH_ALEN] = 0;


--------------090804030806000307000006--
