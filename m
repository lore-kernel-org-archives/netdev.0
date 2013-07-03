From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH V2 2/3] usbnet: cdc_ncm: export cdc_ncm_tx_fixup and
 cdc_ncm_rx_fixup
Date: Wed, 3 Jul 2013 15:00:29 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031455460.24525@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:44176 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721Ab3GCNAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 09:00:10 -0400
Received: by mail-wg0-f47.google.com with SMTP id l18so93681wgh.2
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 06:00:08 -0700 (PDT)
In-Reply-To: <871u7gvz2z.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export cdc_ncm_{tx,rx}_fixup functions, which may be re-used in drivers that 
implement ncm-like protocols.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
v2: removed spurious blank lines


diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 493277e..62686be 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -885,6 +885,7 @@ error:
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
 
 /* verify NTB header and return offset of first NDP, or negative error */
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in)
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
