From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Fri, 25 Apr 2008 16:19:11 +0300
Message-ID: <4811DA4F.30209@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt> <480DA2CA.8090705@teltonika.lt> <480DED38.3080900@teltonika.lt> <480F3C41.10908@teltonika.lt> <4811CF33.8040007@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040607060400050604040604"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4811CF33.8040007-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040607060400050604040604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- simplify net stats even more

--------------040607060400050604040604
Content-Type: text/x-patch;
 name="hso_stats_simplify.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_stats_simplify.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-25 15:12:48.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-25 16:13:41.000000000 +0300
@@ -796,11 +796,11 @@ static int hso_net_start_xmit(struct sk_
 	if (result) {
 		dev_warn(&odev->parent->interface->dev,
 			"failed mux_bulk_tx_urb %d", result);
-		odev->net->stats.tx_errors++;
+		net->stats.tx_errors++;
 		netif_start_queue(net);
 	} else {
-		odev->net->stats.tx_packets++;
-		odev->net->stats.tx_bytes += skb->len;
+		net->stats.tx_packets++;
+		net->stats.tx_bytes += skb->len;
 		/* And tell the kernel when the last transmit started. */
 		net->trans_start = jiffies;
 	}
@@ -840,7 +840,7 @@ static void hso_net_tx_timeout(struct ne
 		usb_unlink_urb(odev->mux_bulk_tx_urb);
 
 	/* Update statistics */
-	odev->net->stats.tx_errors++;
+	net->stats.tx_errors++;
 }
 
 /* make a real packet from the received USB buffer */

--------------040607060400050604040604--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
