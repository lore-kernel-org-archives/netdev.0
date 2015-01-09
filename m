From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: Re: [PATCH net v3] gen_stats.c: Duplicate xstats buffer for later use
Date: Sat, 10 Jan 2015 00:01:09 +0100
Message-ID: <20150109230109.GA4549@zenon.in.qult.net>
References: <20150108123343.GA8541@zenon.in.qult.net>
 <20150108133037.GA10389@zenon.in.qult.net>
 <CAHA+R7OpbP_+iwh6X=sh4SsXJ4VreBjze7dPrV6Xh8RHEe+cGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:60004 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbbAIXB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 18:01:58 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7OpbP_+iwh6X=sh4SsXJ4VreBjze7dPrV6Xh8RHEe+cGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 02:35:41PM -0800, thus spake Cong Wang:
> On Thu, Jan 8, 2015 at 5:30 AM, Ignacy Gaw=EAdzki
> > diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> > index 0c08062..c9f1fa8 100644
> > --- a/net/core/gen_stats.c
> > +++ b/net/core/gen_stats.c
> > @@ -32,6 +32,9 @@ gnet_stats_copy(struct gnet_dump *d, int type, vo=
id *buf, int size)
> >         return 0;
> >
> >  nla_put_failure:
> > +       kfree(d->xstats);
> > +       d->xstats =3D NULL;
> > +       d->xstats_len =3D 0;
> >         spin_unlock_bh(d->lock);
> >         return -1;
> >  }
>=20
> Although it is not your fault, the API sucks, gnet_stats_copy()
> should not need to care about the error path of its caller.
> I will cook a patch for it.

That would be great, as I'm certainly not that fluent in kernel code.

> > @@ -305,7 +308,10 @@ int
> >  gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
> >  {
> >         if (d->compat_xstats) {
> > -               d->xstats =3D st;
> > +               kfree(d->xstats);
> > +               d->xstats =3D kmemdup(st, len, GFP_ATOMIC);
> > +               if (!d->xstats)
> > +                       goto kmalloc_failure;
>=20
> Do we really need to call kfree() before kmemdup()?
> I don't think gnet_stats_copy_app() is supposed to be called
> twice before gnet_stats_copy_finish()?

It's not, but I figured it's safer that way and probably not that expen=
sive
given the frequency with which calls to these functions are performed i=
n
practice.

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
