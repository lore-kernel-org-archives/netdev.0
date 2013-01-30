From: Xi Wang <xi.wang@gmail.com>
Subject: Re: ixp4xx eth broken in 3.7.0/3.8-rc5?
Date: Tue, 29 Jan 2013 19:32:23 -0500
Message-ID: <51086A17.1090707@gmail.com>
References: <20744.9777.937924.822371@pilspetsen.it.uu.se> <20744.25884.660535.514911@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Imre Kaloz <kaloz@openwrt.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f44.google.com ([209.85.212.44]:61309 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab3A3Ac1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 19:32:27 -0500
Received: by mail-vb0-f44.google.com with SMTP id fc26so674255vbb.17
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 16:32:26 -0800 (PST)
In-Reply-To: <20744.25884.660535.514911@pilspetsen.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/13 7:11 PM, Mikael Pettersson wrote:
> A git bisect identified the following as the culprit:
> 
>   > From 1a4901177574083c35fafc24c4d151c2a7c7647c Mon Sep 17 00:00:00 2001
>   > From: Xi Wang <xi.wang@gmail.com>
>   > Date: Sat, 17 Nov 2012 20:25:09 +0000
>   > Subject: [PATCH] ixp4xx_eth: avoid calling dma_pool_create() with NULL dev
>   >
>   > Use &port->netdev->dev instead of NULL since dma_pool_create() doesn't
>   > allow NULL dev.
>   >
>   > Signed-off-by: Xi Wang <xi.wang@gmail.com>
>   > Cc: Andrew Morton <akpm@linux-foundation.org>
>   > Signed-off-by: David S. Miller <davem@davemloft.net>
>   > ---
>   >  drivers/net/ethernet/xscale/ixp4xx_eth.c |    8 +++++---
>   >  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> Reverting this unbreaks ixp4xx_eth on my ixp4xx machine with kernels
> 3.7.0 and 3.8-rc5.

Thanks.  The problem was that in init_queues(), the dma_pool_create()
call requires a non-null dev.

  dma_pool = dma_pool_create(DRV_NAME, ??, ...);

What do you think would work here?
