From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/4] net: add support for per-paged-fragment destructors
Date: Wed, 9 Nov 2011 16:25:14 +0000
Message-ID: <1320855914.955.184.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1320850927-30240-1-git-send-email-ian.campbell@citrix.com>
	 <20111109153300.GA11617@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:58788 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293Ab1KIQZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 11:25:24 -0500
In-Reply-To: <20111109153300.GA11617@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 15:33 +0000, Micha=C5=82 Miros=C5=82aw wrote:
> On Wed, Nov 09, 2011 at 03:02:04PM +0000, Ian Campbell wrote:
> > Entities which care about the complete lifecycle of pages which the=
y inject
> > into the network stack via an skb paged fragment can choose to set =
this
> > destructor in order to receive a callback when the stack is really =
finished
> > with a page (including all clones, retransmits, pull-ups etc etc).
> [...]
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -139,9 +139,16 @@ struct sk_buff;
> > =20
> >  typedef struct skb_frag_struct skb_frag_t;
> > =20
> > +struct skb_frag_destructor {
> > +	atomic_t ref;
> > +	int (*destroy)(void *data);
> > +	void *data;
> > +};
> > +
> >  struct skb_frag_struct {
> >  	struct {
> >  		struct page *p;
> > +		struct skb_frag_destructor *destructor;
> >  	} page;
>=20
> You can get rid of the data field of skb_frag_destructor: if destroy(=
) gets
> pointer to the destroyed struct skb_frag_set_destructor, its users ca=
n
> get at containing struct via container_of() if needed and the memory
> pointed to by data won't have to be managed separately.

At the moment you can share one destructor between all the frags,
whereas data is specific to the frag. At the moment the only user is th=
e
rpc patch which doesn't make use of this capability (i.e. it could use
container_of) but I'm not sure about other potential users yet.

> Nice work, BTW!

Thanks.

>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
