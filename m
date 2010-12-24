From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch] skfp: testing the wrong variable in skfp_driver_init()
Date: Fri, 24 Dec 2010 09:45:39 +0100
Message-ID: <20101224084538.GA2791@psychotron.redhat.com>
References: <20101224051734.GO1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425Ab0LXIpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Dec 2010 03:45:44 -0500
Content-Disposition: inline
In-Reply-To: <20101224051734.GO1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 24, 2010 at 06:17:34AM CET, error27@gmail.com wrote:
>The intent here was to test if the allocation failed but we tested 
>"SharedMemSize" instead of "SharedMemAddr" by mistake.
>
>Signed-off-by: Dan Carpenter <error27@gmail.com>
>
>diff --git a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
>index 0a66fed..16c6265 100644
>--- a/drivers/net/skfp/skfddi.c
>+++ b/drivers/net/skfp/skfddi.c
>@@ -412,7 +412,7 @@ static  int skfp_driver_init(struct net_device *dev)
> 		bp->SharedMemAddr = pci_alloc_consistent(&bp->pdev,
> 							 bp->SharedMemSize,
> 							 &bp->SharedMemDMA);
>-		if (!bp->SharedMemSize) {
>+		if (!bp->SharedMemAddr) {
> 			printk("could not allocate mem for ");
> 			printk("hardware module: %ld byte\n",
> 			       bp->SharedMemSize);

Looks obvious.

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

