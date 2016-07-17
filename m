From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] ravb: fix DMA channel misreporting
Date: Sun, 17 Jul 2016 16:08:43 +0300
Message-ID: <1708843.0O4nJpZ8zM@wasted.cogentembedded.com>
References: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36570 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbcGQNIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 09:08:47 -0400
Received: by mail-lf0-f47.google.com with SMTP id g62so5483903lfe.3
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 06:08:46 -0700 (PDT)
In-Reply-To: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently 'ifconfig' for the Ethernet devices handled by this driver  shows
"DMA chan: ff" while the driver doesn't use any DMA channels. Not assigning
a value to 'net_device::dma' causes 'ifconfig'  to  correctly not report  a
DMA channel.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/ravb_main.c |    1 -
 1 file changed, 1 deletion(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -1909,7 +1909,6 @@ static int ravb_probe(struct platform_de
 
 	/* The Ether-specific entries in the device structure. */
 	ndev->base_addr = res->start;
-	ndev->dma = -1;
 
 	chip_id = (enum ravb_chip_id)of_device_get_match_data(&pdev->dev);
 
