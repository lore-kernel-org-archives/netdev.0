From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 1/4] net: add support for per-paged-fragment destructors
Date: Wed, 9 Nov 2011 18:24:59 +0100
Message-ID: <20111109172459.GA13134@rere.qmqm.pl>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
 <1320850927-30240-1-git-send-email-ian.campbell@citrix.com>
 <20111109153300.GA11617@rere.qmqm.pl>
 <1320855914.955.184.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39260 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270Ab1KIRZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 12:25:03 -0500
Content-Disposition: inline
In-Reply-To: <1320855914.955.184.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 04:25:14PM +0000, Ian Campbell wrote:
> On Wed, 2011-11-09 at 15:33 +0000, Micha=B3 Miros=B3aw wrote:
> > On Wed, Nov 09, 2011 at 03:02:04PM +0000, Ian Campbell wrote:
> > > Entities which care about the complete lifecycle of pages which t=
hey inject
> > > into the network stack via an skb paged fragment can choose to se=
t this
> > > destructor in order to receive a callback when the stack is reall=
y finished
> > > with a page (including all clones, retransmits, pull-ups etc etc)=
=2E
> > [...]
> > > --- a/include/linux/skbuff.h
> > > +++ b/include/linux/skbuff.h
> > > @@ -139,9 +139,16 @@ struct sk_buff;
> > > =20
> > >  typedef struct skb_frag_struct skb_frag_t;
> > > =20
> > > +struct skb_frag_destructor {
> > > +	atomic_t ref;
> > > +	int (*destroy)(void *data);
> > > +	void *data;
> > > +};
> > > +
> > >  struct skb_frag_struct {
> > >  	struct {
> > >  		struct page *p;
> > > +		struct skb_frag_destructor *destructor;
> > >  	} page;
> >=20
> > You can get rid of the data field of skb_frag_destructor: if destro=
y() gets
> > pointer to the destroyed struct skb_frag_set_destructor, its users =
can
> > get at containing struct via container_of() if needed and the memor=
y
> > pointed to by data won't have to be managed separately.
> At the moment you can share one destructor between all the frags,
> whereas data is specific to the frag.
[...]

If you want distinct data pointers then you need to also have per-frag
skb_frag_destructor as you wrote in this patch. So removing 'data' fiel=
d
saves memory but doesn't change anything else except the way to referen=
ce
the data (container_of() instead of pointer dereference).

Best Regards,
Micha=B3 Miros=B3aw
