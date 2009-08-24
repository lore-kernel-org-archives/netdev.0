From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Mon, 24 Aug 2009 08:38:31 +0400
Message-ID: <20090824043831.GA2473@orion>
References: <200908051602.34501.marek.vasut@gmail.com> <200908220054.31438.marek.vasut@gmail.com> <a4423d670908231055o2bb65fe0le2c33fe94b660b38@mail.gmail.com> <20090823.184924.26788268.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.y.miao@gmail.com, linux-arm-kernel@lists.arm.linux.org.uk,
	linux@arm.linux.org.uk, samuel@sortiz.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, marek.vasut@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:49275 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbZHXEie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 00:38:34 -0400
Received: by ewy3 with SMTP id 3so2050239ewy.18
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2009 21:38:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090823.184924.26788268.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 23, 2009 at 06:49:24PM -0700, David Miller wrote:
> From: Alexander Beregalov <a.beregalov@gmail.com>
> Date: Sun, 23 Aug 2009 21:55:45 +0400
> 
> > David, please have a look. Will you apply it?
> 
> Can someone please repost the patch to netdev?  I don't have a copy
> handy and I'd like to see it tracked properly patchwork too.  If it's
> in patchwork, it won't get lost.

>From 28b229f0f3f807d775a7e70b96c018eef935a24a Mon Sep 17 00:00:00 2001
From: Marek Vasut <marek.vasut@gmail.com>
Date: Fri, 24 Jul 2009 02:44:02 +0200
Subject: [PATCH] pxaficp-ir - remove incorrect net_device_ops

This patch fixes broken pxaficp-ir. The problem was in incorrect
net_device_ops being specified which prevented the driver from
operating. The symptoms were:
 - failing ifconfig for IrLAN, resulting in
	SIOCSIFFLAGS: Cannot assign requested address
 - irattach working for IrCOMM, but the port stayed disabled

Moreover this patch corrects missing sysfs device link.

Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
---
 drivers/net/irda/pxaficp_ir.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 4edbdbe..f5b7d83 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -820,9 +820,6 @@ static const struct net_device_ops pxa_irda_netdev_ops = {
 	.ndo_stop		= pxa_irda_stop,
 	.ndo_start_xmit		= pxa_irda_hard_xmit,
 	.ndo_do_ioctl		= pxa_irda_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
 };
 
 static int pxa_irda_probe(struct platform_device *pdev)
@@ -847,6 +844,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	if (!dev)
 		goto err_mem_3;
 
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	si = netdev_priv(dev);
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
-- 
1.6.3.3

