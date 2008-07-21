From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bunch of drivers: avoid BUG at net/core/dev.c:1328
Date: Mon, 21 Jul 2008 08:32:03 -0700 (PDT)
Message-ID: <20080721.083203.22496261.davem@davemloft.net>
References: <20080721151758.GC7989@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42636
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753508AbYGUPcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:32:04 -0400
In-Reply-To: <20080721151758.GC7989@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Mon, 21 Jul 2008 19:17:58 +0400

> The drivers were touching net queue before it has been started, so without
> this patch, the drivers will potentially BUG at net/core/dev.c:1328.
> 
> I don't have the hardware for the drivers below, so this patch is untested,
> and thus should be carefully peer reviewed.
> 
> tc35815.c
> au1000_eth.c
> bfin_mac.c
> macb.c
> ^ The four drivers are using phylib, they're calling netif_start_queue()
> in open() callback. So trivially remove netif_tx_schedule_all().
> Phylib will handle netif_carrier_*().
> 
> cpmac.c
> fec_mpc52xx.c
> fs_enet/fs_enet-main.c
> sh_eth.c
> ^ The same as above, but these were also needlessly calling
> netif_carrier_*() functions. So removed queue calls and also remove
> carrier calls, since phylib will handle it. fs_enet-main.c also didn't
> call netif_start_queue() at open(), this is fixed now.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Your analysis and patch both look accurate, but I'll let this
one sit for a day so that others can have a look and review.

