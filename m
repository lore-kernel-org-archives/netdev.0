From: Manuel Schoelling <manuel.schoelling@gmx.de>
Subject: Re: [PATCH v2] dns_resolver: assure that dns_query() result is
 null-terminated
Date: Sat, 07 Jun 2014 23:53:30 +0200
Message-ID: <1402178010.4806.3.camel@schoellingm.dzne.de>
References: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com>
	 <1402167681-24676-1-git-send-email-manuel.schoelling@gmx.de>
	 <alpine.DEB.2.02.1406071441050.24927@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1406071441050.24927@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sa, 2014-06-07 at 14:42 -0700, David Rientjes wrote:
> On Sat, 7 Jun 2014, Manuel Sch=C3=B6lling wrote:
>=20
> > dns_query() credulously assumes that keys are null-terminated and
> > returns a copy of a memory block that is off by one.
>=20
> No sign-off?  Please read Documentation/SubmittingPatches.
It's just not my day today.
Sorry, I forgot about the sign-off.

> > ---
> >  net/dns_resolver/dns_query.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_qu=
ery.c
> > index e7b6d53..84871a2 100644
> > --- a/net/dns_resolver/dns_query.c
> > +++ b/net/dns_resolver/dns_query.c
> > @@ -145,11 +145,11 @@ int dns_query(const char *type, const char *n=
ame, size_t namelen,
> >  	len =3D upayload->datalen;
> > =20
> >  	ret =3D -ENOMEM;
> > -	*_result =3D kmalloc(len + 1, GFP_KERNEL);
> > +	*_result =3D kzalloc(len + 1, GFP_KERNEL);
> >  	if (!*_result)
> >  		goto put;
> > =20
> > -	memcpy(*_result, upayload->data, len + 1);
> > +	memcpy(*_result, upayload->data, len);
> >  	if (_expiry)
> >  		*_expiry =3D rkey->expiry;
> > =20
>=20
> kzalloc() would be unnecessary overhead (zeroing definitely comes wit=
h a=20
> cost) if you're going to copy to the memory immediately afterwards.  =
Just=20
> leave the kmalloc(), do the memcpy() and explicitly zero terminate it=
=20
> _result.

Using kzalloc() was suggested of a developer on IRC (#kernelnewbies) bu=
t
if you prefer kmalloc, that's ok, too.
I'll send you a corrected patch in a second.
