From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v2] drivers/net/tile/: on-chip network drivers for the
	tile architecture
Date: Sun, 14 Nov 2010 08:52:13 +0100
Message-ID: <20101114075213.GA15495@merkur.ravnborg.org>
References: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com> <20101103125959.3231daa1@s6510> <4CD19DCF.1040709@tilera.com> <1288806622.2511.187.camel@edumazet-laptop> <4CD1BA71.3000806@tilera.com> <1288816300.2718.5.camel@edumazet-laptop> <4CD1CE62.9010307@tilera.com> <201011140335.oAE3Zuqg032279@farm-0027.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:38512 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692Ab0KNHwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 02:52:15 -0500
Content-Disposition: inline
In-Reply-To: <201011140335.oAE3Zuqg032279@farm-0027.internal.tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/drivers/net/tile/Makefile b/drivers/net/tile/Makefile
> new file mode 100644
> index 0000000..f634f14
> --- /dev/null
> +++ b/drivers/net/tile/Makefile
> @@ -0,0 +1,10 @@
> +#
> +# Makefile for the TILE on-chip networking support.
> +#
> +
> +obj-$(CONFIG_TILE_NET) += tile_net.o
> +ifdef CONFIG_TILEGX
> +tile_net-objs := tilegx.o mpipe.o iorpc_mpipe.o dma_queue.o
> +else
> +tile_net-objs := tilepro.o
> +endif

The -objs syntax is deprecated these days.
Preferred syntax for the above is:

ifdef CONFIG_TILEGX
tile_net-y := tilegx.o mpipe.o iorpc_mpipe.o dma_queue.o
else
tile_net-y := tilepro.o
endif

We could make this even shorter like this (assuming TILEGX is a bool):
tile_net-y := tilepro.o
tile_net-$(CONFIG_TILEGX) := tilegx.o mpipe.o iorpc_mpipe.o dma_queue.o

But this is less readable - so the longer version is better.


	Sam
