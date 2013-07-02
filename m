From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH RFC] cdc_ncm.c: make rx and tx functions exportable
Date: Tue, 2 Jul 2013 12:43:40 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: bjorn@mork.no, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:55462 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab3GBKnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 06:43:20 -0400
Received: by mail-wi0-f177.google.com with SMTP id ey16so4058365wid.16
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 03:43:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch factors out rx and tx fixup functions from cdc_ncm.c driver.
This will be useful once implementing a specific driverto handle huawei 
specific ncm implementation.


diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 43afde8..7fdd7b9 100644
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
