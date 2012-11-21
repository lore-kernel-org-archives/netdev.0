From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netfront: handle compound page fragments on transmit
Date: Wed, 21 Nov 2012 11:09:28 +0000
Message-ID: <1353496168.13542.120.camel@zakaz.uk.xensource.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
	 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
	 <50AC41F7.7080609@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	"Sander Eikelenboom" <linux@eikelenboom.it>,
	Stefan Bader <stefan.bader@canonical.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:46651 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598Ab2KULJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:09:30 -0500
In-Reply-To: <50AC41F7.7080609@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 02:52 +0000, ANNIE LI wrote:
> 
> On 2012-11-20 19:40, Ian Campbell wrote:
> > An SKB paged fragment can consist of a compound page with order>  0.
> > However the netchannel protocol deals only in PAGE_SIZE frames.
> >
> > Handle this in xennet_make_frags by iterating over the frames which
> > make up the page.
> >
> > This is the netfront equivalent to 6a8ed462f16b for netback.
> >
> > Signed-off-by: Ian Campbell<ian.campbell@citrix.com>
> > Cc: netdev@vger.kernel.org
> > Cc: xen-devel@lists.xen.org
> > Cc: Eric Dumazet<edumazet@google.com>
> > Cc: Konrad Rzeszutek Wilk<konrad@kernel.org>
> > Cc: ANNIE LI<annie.li@oracle.com>
> > Cc: Sander Eikelenboom<linux@eikelenboom.it>
> > Cc: Stefan Bader<stefan.bader@canonical.com>
> > ---
> >   drivers/net/xen-netfront.c |   58 +++++++++++++++++++++++++++++++++----------
> >   1 files changed, 44 insertions(+), 14 deletions(-)
> >
> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index caa0110..a12b99a 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -452,24 +452,54 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
> >   	/* Grant backend access to each skb fragment page. */
> >   	for (i = 0; i<  frags; i++) {
> >   		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
> > +		struct page *page = skb_frag_page(frag);
> > +		unsigned long size = skb_frag_size(frag);
> > +		unsigned long offset = frag->page_offset;
> 
> There are following definitions at the beginning of xennet_make_frags,
> 
>          unsigned int offset = offset_in_page(data);
>          unsigned int len = skb_headlen(skb);

So they are, well spotted.

> Is it better to reuse those definitions, and not define new size and 
> offset again in this for loop? And unsigned int is enough here, right?

Yes to both.
> [...]
> Over 80 characters?
[...]
> Over 80 characters?

Both fixed, thanks for your review.

Ian.
