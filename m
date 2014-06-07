From: Manuel Schoelling <manuel.schoelling@gmx.de>
Subject: Re: [PATCH] dns_resolver: assure that dns_query() result is
 null-terminated
Date: Sat, 07 Jun 2014 20:57:32 +0200
Message-ID: <1402167452.4806.0.camel@schoellingm.dzne.de>
References: <1402163811-21604-1-git-send-email-manuel.schoelling@gmx.de>
	 <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Miller David S." <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel mailing list <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHQdGtTtwS_DAXx-nhVjjO3D1wksuV+5br10gX0DheHzWDD+sw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

LOL, that was stupid!
Sorry, I'll send a corrected version in a second...

On Sa, 2014-06-07 at 14:54 -0400, Trond Myklebust wrote:
> On Sat, Jun 7, 2014 at 1:56 PM, Manuel Sch=C3=B6lling
> <manuel.schoelling@gmx.de> wrote:
> > dns_query() credulously assumes that keys are null-terminated and
> > returns a copy of a memory block that is off by one.
> > ---
> >  net/dns_resolver/dns_query.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_qu=
ery.c
> > index e7b6d53..53be635 100644
> > --- a/net/dns_resolver/dns_query.c
> > +++ b/net/dns_resolver/dns_query.c
> > @@ -149,7 +149,9 @@ int dns_query(const char *type, const char *nam=
e, size_t namelen,
> >         if (!*_result)
> >                 goto put;
> >
> > -       memcpy(*_result, upayload->data, len + 1);
> > +       memcpy(*_result, upayload->data, len);
> > +       *_result[len+1] =3D '\0';
>=20
> Off by one...
>=20
> > +
> >         if (_expiry)
> >                 *_expiry =3D rkey->expiry;
> >
> > --
> > 1.7.10.4
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-ker=
nel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20
>=20
