From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH 1/3] net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions
 for re-use
Date: Wed, 10 Jul 2013 14:27:20 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307101425310.22696@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:51029 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab3GJM06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 08:26:58 -0400
Received: by mail-ee0-f43.google.com with SMTP id l10so4774797eei.2
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 05:26:57 -0700 (PDT)
In-Reply-To: <87wqp9xja5.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers implementing NCM-like protocols, may re-use those functions, as is 
the case in the huawei_cdc_ncm driver.
Export them via EXPORT_SYMBOL_GPL.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c   |    6 ++++--
 include/linux/usb/cdc_ncm.h |    3 +++
 2 files changed, 7 insertions(+), 2 deletions(-)

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
