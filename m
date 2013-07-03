From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH V2 1/3] usbnet: cdc_ncm: let cdc_ncm_tx_fixup and cdc_ncm_rx_fixup
 be non-static
Date: Wed, 3 Jul 2013 14:55:37 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031450250.24525@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:49403 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966Ab3GCMzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 08:55:20 -0400
Received: by mail-we0-f182.google.com with SMTP id p60so89004wes.13
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 05:55:18 -0700 (PDT)
In-Reply-To: <871u7gvz2z.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make those functions non-static so that they can be exported and re-used in 
other drivers.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>


diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 43afde8..493277e 100644
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
@@ -965,7 +965,7 @@ error:
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_rx_verify_ndp16);
 
-static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
+int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 {
 	struct sk_buff *skb;
 	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
