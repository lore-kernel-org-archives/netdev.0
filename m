From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 10:45:24 -0800
Message-ID: <20071107104524.2bd738cb@freepuppy.rosehill>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.boeing.com>
	<20071108.033650.113099372.yoshfuji@linux-ipv6.org>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDBF3@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60278 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755010AbXKGSqx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 13:46:53 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF3@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Nov 2007 10:41:49 -0800
"Templin, Fred L" <Fred.L.Templin@boeing.com> wrote:

> Yoshifuji,=20
>=20
> > -----Original Message-----
> > From: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E [mai=
lto:yoshfuji@linux-ipv6.org]=20
> > Sent: Wednesday, November 07, 2007 10:37 AM
> > To: Templin, Fred L
> > Cc: netdev@vger.kernel.org; yoshfuji@linux-ipv6.org
> > Subject: Re: [PATCH 04/05] ipv6: RFC4214 Support
> >=20
> > Hello.
> >=20
> > In article=20
> > <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE5@XCH-NW-7V2.nw.nos.bo
> > eing.com> (at Tue, 6 Nov 2007 17:16:11 -0800), "Templin, Fred=20
> > L" <Fred.L.Templin@boeing.com> says:
> >=20
> > > @@ -154,6 +155,14 @@ static struct ip_tunnel * ipip6_tunnel_l
> > >  	struct net_device *dev;
> > >  	char name[IFNAMSIZ];
> > > =20
> > > +#if defined(CONFIG_IPV6_ISATAP)
> > > +	/* ISATAP (RFC4214) - router address in daddr */
> > > +	if (!strncmp(parms->name, "isatap", 6)) {
> > > +		parms->i_key =3D parms->iph.daddr;
> > > +		parms->iph.daddr =3D remote =3D 0;
> > > +	}
> > > +#endif
> > > +
> > >  	for (tp =3D __ipip6_bucket(parms); (t =3D *tp) !=3D NULL; tp =3D
> > > &t->next) {
> > >  		if (local =3D=3D t->parms.iph.saddr && remote =3D=3D
> > > t->parms.iph.daddr)
> > >  			return t;
> >=20
> > I do not think it is a good idea to change the behavior based on
> > the interface name.
>=20
> The goal was to avoid requiring changes to applications such as
> 'iproute2', i.e., the intention was for a standalone code insertion p=
oint
> within the kernel itself. What do you suggest?

Agreed, magic names are evil.

Change iproute2 utilities, if it is more logical for administration.


--=20
Stephen Hemminger <shemminger@linux-foundation.org>
