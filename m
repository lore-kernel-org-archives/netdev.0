From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: fix DMA channel misreporting
Date: Sun, 17 Jul 2016 16:09:19 +0300
Message-ID: <3458874.GvGScMe9De@wasted.cogentembedded.com>
References: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35054 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbcGQNJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 09:09:23 -0400
Received: by mail-lf0-f45.google.com with SMTP id f93so115504744lfi.2
        for <netdev@vger.kernel.org>; Sun, 17 Jul 2016 06:09:23 -0700 (PDT)
In-Reply-To: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently 'ifconfig' for the Ethernet devices handled by this driver  shows
"DMA chan: ff" while the driver doesn't use any DMA channels. Not assigning
a value to 'net_device::dma' causes 'ifconfig'  to  correctly not report  a
DMA channel.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    1 -
 1 file changed, 1 deletion(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -2996,7 +2996,6 @@ static int sh_eth_drv_probe(struct platf
 	if (devno < 0)
 		devno = 0;
 
-	ndev->dma = -1;
 	ret = platform_get_irq(pdev, 0);
 	if (ret < 0)
 		goto out_release;
