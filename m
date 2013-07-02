From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH 1/3] Export cdc_ncm_{tx,rx}_fixup functions
Date: Tue, 2 Jul 2013 22:10:27 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38081 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab3GBUKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 16:10:08 -0400
Received: by mail-wi0-f172.google.com with SMTP id c10so4548795wiw.17
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 13:10:07 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.02.1307022202570.26010@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exports those functions to be able to re-use them in other drivers if needed.

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 493277e..22ed51c 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -885,6 +885,8 @@ error:
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_tx_fixup);
+
 
 /* verify NTB header and return offset of first NDP, or negative error */
 int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in)
@@ -1040,6 +1042,7 @@ err_ndp:
 error:
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cdc_ncm_rx_fixup);
 
 static void
 cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index cc25b70..163244b 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -133,3 +133,6 @@ extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
 extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb, __le32 sign);
 extern int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_buff *skb_in);
 extern int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffset);
+struct sk_buff *
+cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in);
