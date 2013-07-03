From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH V3 1/2] Export cdc_ncm_{tx,rx]_fixup functions
Date: Wed, 3 Jul 2013 15:33:14 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031529540.25440@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no> <alpine.LNX.2.02.1307031455460.24525@eeeadesso>
 <51D424D1.2010507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:64370 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3GCNcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 09:32:54 -0400
Received: by mail-wg0-f50.google.com with SMTP id k14so125967wgh.17
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 06:32:53 -0700 (PDT)
In-Reply-To: <51D424D1.2010507@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers implementing NCM-like protocols may re-use these functions. So 
export them.

Signed-off-by: enrico Mioso <mrkiko.rs@gmail.com>
v3: merged the two patches who make up this one

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 43afde8..62686be 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -858,7 +858,7 @@ static void cdc_ncm_txpath_bh(unsigned long param)
 	}
 }
 
-static struct sk_buff *
+struct sk_buff *
 cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
 	struct sk_buff *skb_out;
@@ -885,6 +885,7 @@ error:
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
 
 /* verify NTB header and return offset of first NDP, or negative error */
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in)
@@ -965,7 +966,7 @@ error:
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_ndp16);
 
-static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 {
 	struct sk_buff *skb;
 	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
@@ -1040,6 +1041,7 @@ err_ndp:
 error:
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_rx_fixup);
 
 static void
 cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index cc25b70..7a97cda 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -133,3 +133,5 @@ extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
 extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign);
 extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in);
 extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
+struct sk_buff *cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);
