From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio: Net header needs gso_hdr_len
Date: Wed, 16 Jan 2008 15:19:03 +1100
Message-ID: <200801161519.03339.rusty@rustcorp.com.au>
References: <E1JEvnR-0006ax-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44022 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229AbYAPETf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 23:19:35 -0500
In-Reply-To: <E1JEvnR-0006ax-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 January 2008 11:06:21 Herbert Xu wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > It's far easier to deal with GSO if we don't have to parse the packet
> > to figure out the header length.  Add the field to the virtio_net_hdr
> > struct (and fix the spaces that somehow crept in there).
> >
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> > ---
> > drivers/net/virtio_net.c   |    4 +++-
> > include/linux/virtio_net.h |   11 ++++++-----
> > 2 files changed, 9 insertions(+), 6 deletions(-)
> >
> > diff -r 24ef33a4ab14 drivers/net/virtio_net.c
> > --- a/drivers/net/virtio_net.c  Tue Jan 15 16:59:58 2008 +1100
> > +++ b/drivers/net/virtio_net.c  Tue Jan 15 21:21:40 2008 +1100
> > @@ -126,6 +126,7 @@ static void receive_skb(struct net_devic
> >                /* Header must be checked, and gso_segs computed. */
> >                skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
> >                skb_shinfo(skb)->gso_segs = 0;
> > +               skb_set_transport_header(skb, hdr->gso_hdr_len);
>
> Why do we need this? When receiving GSO packets from an untrusted
> source the network stack will fill in the transport header offset
> after verifying that the headers are sane.

Thanks for clarifying; it simplifies things.

I'll re-test and resend.
Rusty.
