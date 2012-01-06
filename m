From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 3/6] net: add support for per-paged-fragment destructors
Date: Fri, 6 Jan 2012 08:50:31 +0000
Message-ID: <1325839831.25206.423.camel@zakaz.uk.xensource.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-3-git-send-email-ian.campbell@citrix.com>
	 <20120106011524.GA10975@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:30291 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133Ab2AFIud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 03:50:33 -0500
In-Reply-To: <20120106011524.GA10975@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-06 at 01:15 +0000, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, Jan 05, 2012 at 05:13:41PM +0000, Ian Campbell wrote:
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
> > @@ -143,9 +143,16 @@ struct sk_buff;
> > =20
> >  typedef struct skb_frag_struct skb_frag_t;
> > =20
> > +struct skb_frag_destructor {
> > +	atomic_t ref;
> > +	int (*destroy)(void *data);
> > +	void *data;
> > +};
> > +
> [...]
>=20
> What happened to removal of 'data' field from this structure?

I did that in my branch where I also moved the *page into there (to try
and shrink the frag size) and forgot to rescue it when I switched back.
I'll make the change again for next time.

Thanks for the reminder.

Ian.
