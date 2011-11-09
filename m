From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/4] net: add support for per-paged-fragment destructors
Date: Wed, 9 Nov 2011 17:28:58 +0000
Message-ID: <1320859738.955.190.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1320850927-30240-1-git-send-email-ian.campbell@citrix.com>
	 <20111109153300.GA11617@rere.qmqm.pl>
	 <1320855914.955.184.camel@zakaz.uk.xensource.com>
	 <20111109172459.GA13134@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:12169 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab1KIR3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 12:29:00 -0500
In-Reply-To: <20111109172459.GA13134@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 17:24 +0000, Micha=C5=82 Miros=C5=82aw wrote:
> On Wed, Nov 09, 2011 at 04:25:14PM +0000, Ian Campbell wrote:
> > On Wed, 2011-11-09 at 15:33 +0000, Micha=C5=82 Miros=C5=82aw wrote:
> > > On Wed, Nov 09, 2011 at 03:02:04PM +0000, Ian Campbell wrote:
> > > > Entities which care about the complete lifecycle of pages which=
 they inject
> > > > into the network stack via an skb paged fragment can choose to =
set this
> > > > destructor in order to receive a callback when the stack is rea=
lly finished
> > > > with a page (including all clones, retransmits, pull-ups etc et=
c).
> > > [...]
> > > > --- a/include/linux/skbuff.h
> > > > +++ b/include/linux/skbuff.h
> > > > @@ -139,9 +139,16 @@ struct sk_buff;
> > > > =20
> > > >  typedef struct skb_frag_struct skb_frag_t;
> > > > =20
> > > > +struct skb_frag_destructor {
> > > > +	atomic_t ref;
> > > > +	int (*destroy)(void *data);
> > > > +	void *data;
> > > > +};
> > > > +
> > > >  struct skb_frag_struct {
> > > >  	struct {
> > > >  		struct page *p;
> > > > +		struct skb_frag_destructor *destructor;
> > > >  	} page;
> > >=20
> > > You can get rid of the data field of skb_frag_destructor: if dest=
roy() gets
> > > pointer to the destroyed struct skb_frag_set_destructor, its user=
s can
> > > get at containing struct via container_of() if needed and the mem=
ory
> > > pointed to by data won't have to be managed separately.
> > At the moment you can share one destructor between all the frags,
> > whereas data is specific to the frag.
> [...]
>=20
> If you want distinct data pointers then you need to also have per-fra=
g
> skb_frag_destructor as you wrote in this patch. So removing 'data' fi=
eld
> saves memory but doesn't change anything else except the way to refer=
ence
> the data (container_of() instead of pointer dereference).

Oh yes, you are absolutely right.

Ian.

>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
