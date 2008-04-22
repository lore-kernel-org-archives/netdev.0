From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Tue, 22 Apr 2008 11:33:14 +0300
Message-ID: <480DA2CA.8090705@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080205030002080400070903"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480CB8C2.9090902-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080205030002080400070903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- use net_device_stats from dev->stats

--------------080205030002080400070903
Content-Type: text/x-patch;
 name="hso_net_stats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_net_stats.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-21 18:45:43.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-22 11:16:01.000000000 +0300
@@ -152,7 +152,6 @@ struct hso_shared_int {
 
 struct hso_net {
 	struct hso_device *parent;
-	struct net_device_stats stats;
 	struct net_device *net;
 
 	struct usb_endpoint_descriptor *in_endp;
@@ -712,7 +711,7 @@ static int hso_net_open(struct net_devic
 		return -ENODEV;
 	}
 	/* reset read counter. */
-	odev->stats.rx_packets = 0;
+	odev->net->stats.rx_packets = 0;
 	odev->skb_tx_buf = NULL;
 
 	/* setup environment */
@@ -817,11 +816,11 @@ static int hso_net_start_xmit(struct sk_
 	if (result) {
 		dev_warn(&odev->parent->interface->dev,
 			"failed mux_bulk_tx_urb %d", result);
-		odev->stats.tx_errors++;
+		odev->net->stats.tx_errors++;
 		netif_start_queue(net);
 	} else {
-		odev->stats.tx_packets++;
-		odev->stats.tx_bytes += skb->len;
+		odev->net->stats.tx_packets++;
+		odev->net->stats.tx_bytes += skb->len;
 		/* And tell the kernel when the last transmit started. */
 		net->trans_start = jiffies;
 	}
@@ -846,7 +845,7 @@ static struct ethtool_ops ops = {
 
 static struct net_device_stats *hso_net_get_stats(struct net_device *net)
 {
-	return &((struct hso_net *)netdev_priv(net))->stats;
+	return &net->stats;
 }
 
 /* called when a packet did not ack after watchdogtimeout */
@@ -866,7 +865,7 @@ static void hso_net_tx_timeout(struct ne
 		usb_unlink_urb(odev->mux_bulk_tx_urb);
 
 	/* Update statistics */
-	odev->stats.tx_errors++;
+	odev->net->stats.tx_errors++;
 }
 
 /* make a real packet from the received USB buffer */
@@ -991,11 +990,11 @@ static void packetizeRx(struct hso_net *
 				odev->skb_rx_buf = NULL;
 
 				/* update out statistics */
-				odev->stats.rx_packets++;
+				odev->net->stats.rx_packets++;
 
 				/* Hmmm, wonder if we have received the IP len
 				 * or the ETH len. */
-				odev->stats.rx_bytes += odev->rx_buf_size;
+				odev->net->stats.rx_bytes += odev->rx_buf_size;
 
 				odev->rx_buf_size = 0;
 				odev->rx_buf_missing = sizeof(struct iphdr);

--------------080205030002080400070903--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
