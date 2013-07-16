From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/9] sfc: Increase size of RX SKB header area
Date: Tue, 16 Jul 2013 18:53:48 +0100
Message-ID: <1373997228.2120.15.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
	 <1372104801.1896.32.camel@bwh-desktop.uk.level5networks.com>
	 <1373996035.6097.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:27090 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337Ab3GPRxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 13:53:53 -0400
In-Reply-To: <1373996035.6097.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 10:33 -0700, Eric Dumazet wrote:
> On Mon, 2013-06-24 at 21:13 +0100, Ben Hutchings wrote:
> > From: Jon Cooper <jcooper@solarflare.com>
> > 
> > This allows the SKB to hold the headers without reallocation more often.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/ethernet/sfc/rx.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
> > index b915e09..6efff3d 100644
> > --- a/drivers/net/ethernet/sfc/rx.c
> > +++ b/drivers/net/ethernet/sfc/rx.c
> > @@ -36,7 +36,7 @@
> >  #define EFX_RECYCLE_RING_SIZE_NOIOMMU (2 * EFX_RX_PREFERRED_BATCH)
> >  
> >  /* Size of buffer allocated for skb header area. */
> > -#define EFX_SKB_HEADERS  64u
> > +#define EFX_SKB_HEADERS  128u
> >  
> >  /* This is the percentage fill level below which new RX descriptors
> >   * will be added to the RX descriptor ring.
> > 
> 
> This patch brings performance decrease for tunnels, because it pulls
> into skb->head 128 bytes worth of data.
>
> This includes TCP payload, so GRO or TCP coalescing code is less
> effective. Each MSS spans 2 memory areas (small part on skb->head,
> remaining on the fragment) : GRO packets have only 8 MSS worth of data,
> instead of 16.
> 
> The fix would be to allocate 128 bytes in skb->head to prevent future
> reallocations of skb->head, but pull 64 bytes only.

Perhaps, yes.  I also thought of using some of the other parser status
from RX completions to estimate the length of headers.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
