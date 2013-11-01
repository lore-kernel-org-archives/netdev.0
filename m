From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 17/24] net: cdc_ncm: use netif_* and dev_* instead of pr_*
Date: Fri,  1 Nov 2013 11:16:54 +0100
Message-ID: <1383301021-16613-18-git-send-email-bjorn@mork.no>
References: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49970 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755917Ab3KAKRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:23 -0400
In-Reply-To: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of standard device name prefixing and
netdevice msglvl control where possible.

Cc: Alexey Orishko <alexey.orishko@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   98 ++++++++++++++++++++++---------------=
--------
 1 file changed, 48 insertions(+), 50 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b5fdf8f..73faf05 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -87,7 +87,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 			      0, iface_no, &ncm_parm,
 			      sizeof(ncm_parm));
 	if (err < 0) {
-		pr_debug("failed GET_NTB_PARAMETERS\n");
+		dev_dbg(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
 		return 1;
 	}
=20
@@ -115,11 +115,10 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 		flags =3D 0;
 	}
=20
-	pr_debug("dwNtbInMaxSize=3D%u dwNtbOutMaxSize=3D%u "
-		 "wNdpOutPayloadRemainder=3D%u wNdpOutDivisor=3D%u "
-		 "wNdpOutAlignment=3D%u wNtbOutMaxDatagrams=3D%u flags=3D0x%x\n",
-		 ctx->rx_max, ctx->tx_max, ctx->tx_remainder, ctx->tx_modulus,
-		 ctx->tx_ndp_modulus, ctx->tx_max_datagrams, flags);
+	dev_dbg(&dev->intf->dev,
+		"dwNtbInMaxSize=3D%u dwNtbOutMaxSize=3D%u wNdpOutPayloadRemainder=3D=
%u wNdpOutDivisor=3D%u wNdpOutAlignment=3D%u wNtbOutMaxDatagrams=3D%u f=
lags=3D0x%x\n",
+		ctx->rx_max, ctx->tx_max, ctx->tx_remainder, ctx->tx_modulus,
+		ctx->tx_ndp_modulus, ctx->tx_max_datagrams, flags);
=20
 	/* max count of tx datagrams */
 	if ((ctx->tx_max_datagrams =3D=3D 0) ||
@@ -128,14 +127,14 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
=20
 	/* verify maximum size of received NTB in bytes */
 	if (ctx->rx_max < USB_CDC_NCM_NTB_MIN_IN_SIZE) {
-		pr_debug("Using min receive length=3D%d\n",
-						USB_CDC_NCM_NTB_MIN_IN_SIZE);
+		dev_dbg(&dev->intf->dev, "Using min receive length=3D%d\n",
+			USB_CDC_NCM_NTB_MIN_IN_SIZE);
 		ctx->rx_max =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
 	}
=20
 	if (ctx->rx_max > CDC_NCM_NTB_MAX_SIZE_RX) {
-		pr_debug("Using default maximum receive length=3D%d\n",
-						CDC_NCM_NTB_MAX_SIZE_RX);
+		dev_dbg(&dev->intf->dev, "Using default maximum receive length=3D%d\=
n",
+			CDC_NCM_NTB_MAX_SIZE_RX);
 		ctx->rx_max =3D CDC_NCM_NTB_MAX_SIZE_RX;
 	}
=20
@@ -148,15 +147,15 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 				       | USB_RECIP_INTERFACE,
 				       0, iface_no, &dwNtbInMaxSize, 4);
 		if (err < 0)
-			pr_debug("Setting NTB Input Size failed\n");
+			dev_dbg(&dev->intf->dev, "Setting NTB Input Size failed\n");
 	}
=20
 	/* verify maximum size of transmitted NTB in bytes */
 	if ((ctx->tx_max <
 	    (min_hdr_size + min_dgram_size)) ||
 	    (ctx->tx_max > CDC_NCM_NTB_MAX_SIZE_TX)) {
-		pr_debug("Using default maximum transmit length=3D%d\n",
-						CDC_NCM_NTB_MAX_SIZE_TX);
+		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D%d=
\n",
+			CDC_NCM_NTB_MAX_SIZE_TX);
 		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
=20
 		/* Adding a pad byte here simplifies the handling in
@@ -178,7 +177,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
=20
 	if ((val < USB_CDC_NCM_NDP_ALIGN_MIN_SIZE) ||
 	    (val !=3D ((-val) & val)) || (val >=3D ctx->tx_max)) {
-		pr_debug("Using default alignment: 4 bytes\n");
+		dev_dbg(&dev->intf->dev, "Using default alignment: 4 bytes\n");
 		ctx->tx_ndp_modulus =3D USB_CDC_NCM_NDP_ALIGN_MIN_SIZE;
 	}
=20
@@ -192,13 +191,13 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
=20
 	if ((val < USB_CDC_NCM_NDP_ALIGN_MIN_SIZE) ||
 	    (val !=3D ((-val) & val)) || (val >=3D ctx->tx_max)) {
-		pr_debug("Using default transmit modulus: 4 bytes\n");
+		dev_dbg(&dev->intf->dev, "Using default transmit modulus: 4 bytes\n"=
);
 		ctx->tx_modulus =3D USB_CDC_NCM_NDP_ALIGN_MIN_SIZE;
 	}
=20
 	/* verify the payload remainder */
 	if (ctx->tx_remainder >=3D ctx->tx_modulus) {
-		pr_debug("Using default transmit remainder: 0 bytes\n");
+		dev_dbg(&dev->intf->dev, "Using default transmit remainder: 0 bytes\=
n");
 		ctx->tx_remainder =3D 0;
 	}
=20
@@ -216,7 +215,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 				       USB_CDC_NCM_CRC_NOT_APPENDED,
 				       iface_no, NULL, 0);
 		if (err < 0)
-			pr_debug("Setting CRC mode off failed\n");
+			dev_dbg(&dev->intf->dev, "Setting CRC mode off failed\n");
 	}
=20
 	/* set NTB format, if both formats are supported */
@@ -227,7 +226,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 				       USB_CDC_NCM_NTB16_FORMAT,
 				       iface_no, NULL, 0);
 		if (err < 0)
-			pr_debug("Setting NTB format to 16-bit failed\n");
+			dev_dbg(&dev->intf->dev, "Setting NTB format to 16-bit failed\n");
 	}
=20
 	ctx->max_datagram_size =3D min_dgram_size;
@@ -248,8 +247,8 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 				      | USB_RECIP_INTERFACE,
 				      0, iface_no, &max_datagram_size, 2);
 		if (err < 0) {
-			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=3D%u\n",
-				 min_dgram_size);
+			dev_dbg(&dev->intf->dev, "GET_MAX_DATAGRAM_SIZE failed, use size=3D=
%u\n",
+				min_dgram_size);
 		} else {
 			ctx->max_datagram_size =3D
 				le16_to_cpu(max_datagram_size);
@@ -275,7 +274,7 @@ static u8 cdc_ncm_setup(struct usbnet *dev)
 						iface_no, &max_datagram_size,
 						2);
 				if (err < 0)
-					pr_debug("SET_MAX_DGRAM_SIZE failed\n");
+					dev_dbg(&dev->intf->dev, "SET_MAX_DGRAM_SIZE failed\n");
 			}
 		}
 	}
@@ -867,6 +866,7 @@ error:
 /* verify NTB header and return offset of first NDP, or negative error=
 */
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *s=
kb_in)
 {
+	struct usbnet *dev =3D netdev_priv(skb_in->dev);
 	struct usb_cdc_ncm_nth16 *nth16;
 	int len;
 	int ret =3D -EINVAL;
@@ -876,7 +876,7 @@ int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx=
, struct sk_buff *skb_in)
=20
 	if (skb_in->len < (sizeof(struct usb_cdc_ncm_nth16) +
 					sizeof(struct usb_cdc_ncm_ndp16))) {
-		pr_debug("frame too short\n");
+		netif_dbg(dev, rx_err, dev->net, "frame too short\n");
 		goto error;
 	}
=20
@@ -890,16 +890,18 @@ int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *c=
tx, struct sk_buff *skb_in)
=20
 	len =3D le16_to_cpu(nth16->wBlockLength);
 	if (len > ctx->rx_max) {
-		pr_debug("unsupported NTB block length %u/%u\n", len,
-								ctx->rx_max);
+		netif_dbg(dev, rx_err, dev->net,
+			  "unsupported NTB block length %u/%u\n", len,
+			  ctx->rx_max);
 		goto error;
 	}
=20
 	if ((ctx->rx_seq + 1) !=3D le16_to_cpu(nth16->wSequence) &&
-		(ctx->rx_seq || le16_to_cpu(nth16->wSequence)) &&
-		!((ctx->rx_seq =3D=3D 0xffff) && !le16_to_cpu(nth16->wSequence))) {
-		pr_debug("sequence number glitch prev=3D%d curr=3D%d\n",
-				ctx->rx_seq, le16_to_cpu(nth16->wSequence));
+	    (ctx->rx_seq || le16_to_cpu(nth16->wSequence)) &&
+	    !((ctx->rx_seq =3D=3D 0xffff) && !le16_to_cpu(nth16->wSequence)))=
 {
+		netif_dbg(dev, rx_err, dev->net,
+			  "sequence number glitch prev=3D%d curr=3D%d\n",
+			  ctx->rx_seq, le16_to_cpu(nth16->wSequence));
 	}
 	ctx->rx_seq =3D le16_to_cpu(nth16->wSequence);
=20
@@ -912,18 +914,20 @@ EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_nth16);
 /* verify NDP header and return number of datagrams, or negative error=
 */
 int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset)
 {
+	struct usbnet *dev =3D netdev_priv(skb_in->dev);
 	struct usb_cdc_ncm_ndp16 *ndp16;
 	int ret =3D -EINVAL;
=20
 	if ((ndpoffset + sizeof(struct usb_cdc_ncm_ndp16)) > skb_in->len) {
-		pr_debug("invalid NDP offset  <%u>\n", ndpoffset);
+		netif_dbg(dev, rx_err, dev->net, "invalid NDP offset  <%u>\n",
+			  ndpoffset);
 		goto error;
 	}
 	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
=20
 	if (le16_to_cpu(ndp16->wLength) < USB_CDC_NCM_NDP16_LENGTH_MIN) {
-		pr_debug("invalid DPT16 length <%u>\n",
-			 le16_to_cpu(ndp16->wLength));
+		netif_dbg(dev, rx_err, dev->net, "invalid DPT16 length <%u>\n",
+			  le16_to_cpu(ndp16->wLength));
 		goto error;
 	}
=20
@@ -932,9 +936,9 @@ int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in,=
 int ndpoffset)
 					sizeof(struct usb_cdc_ncm_dpe16));
 	ret--; /* we process NDP entries except for the last one */
=20
-	if ((sizeof(struct usb_cdc_ncm_ndp16) + ret * (sizeof(struct usb_cdc_=
ncm_dpe16))) >
-								skb_in->len) {
-		pr_debug("Invalid nframes =3D %d\n", ret);
+	if ((sizeof(struct usb_cdc_ncm_ndp16) +
+	     ret * (sizeof(struct usb_cdc_ncm_dpe16))) > skb_in->len) {
+		netif_dbg(dev, rx_err, dev->net, "Invalid nframes =3D %d\n", ret);
 		ret =3D -EINVAL;
 	}
=20
@@ -991,9 +995,9 @@ next_ndp:
 		/* sanity checking */
 		if (((offset + len) > skb_in->len) ||
 				(len > ctx->rx_max) || (len < ETH_HLEN)) {
-			pr_debug("invalid frame detected (ignored)"
-					"offset[%u]=3D%u, length=3D%u, skb=3D%p\n",
-					x, offset, len, skb_in);
+			netif_dbg(dev, rx_err, dev->net,
+				  "invalid frame detected (ignored) offset[%u]=3D%u, length=3D%u, =
skb=3D%p\n",
+				  x, offset, len, skb_in);
 			if (!x)
 				goto err_ndp;
 			break;
@@ -1031,17 +1035,13 @@ cdc_ncm_speed_change(struct usbnet *dev,
 	 * device speed. Do print it instead.
 	 */
 	if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
-		printk(KERN_INFO KBUILD_MODNAME
-		       ": %s: %u mbit/s downlink "
-		       "%u mbit/s uplink\n",
-		       dev->net->name,
+		netif_info(dev, link, dev->net,
+		       "%u mbit/s downlink %u mbit/s uplink\n",
 		       (unsigned int)(rx_speed / 1000000U),
 		       (unsigned int)(tx_speed / 1000000U));
 	} else {
-		printk(KERN_INFO KBUILD_MODNAME
-		       ": %s: %u kbit/s downlink "
-		       "%u kbit/s uplink\n",
-		       dev->net->name,
+		netif_info(dev, link, dev->net,
+		       "%u kbit/s downlink %u kbit/s uplink\n",
 		       (unsigned int)(rx_speed / 1000U),
 		       (unsigned int)(tx_speed / 1000U));
 	}
@@ -1074,11 +1074,9 @@ static void cdc_ncm_status(struct usbnet *dev, s=
truct urb *urb)
 		 * sent by device after USB_CDC_NOTIFY_SPEED_CHANGE.
 		 */
 		ctx->connected =3D le16_to_cpu(event->wValue);
-
-		printk(KERN_INFO KBUILD_MODNAME ": %s: network connection:"
-		       " %sconnected\n",
-		       dev->net->name, ctx->connected ? "" : "dis");
-
+		netif_info(dev, link, dev->net,
+			   "network connection: %sconnected\n",
+			   ctx->connected ? "" : "dis");
 		usbnet_link_change(dev, ctx->connected, 0);
 		break;
=20
--=20
1.7.10.4
