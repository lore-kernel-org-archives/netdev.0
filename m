From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 1/6] tipc: allow connection shutdown
 callback to be invoked in advance
Date: Sun, 09 Mar 2014 17:48:09 +0000
Message-ID: <1394387289.2861.175.camel@deadeye.wl.decadent.org.uk>
References: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
	 <1394006178-23966-2-git-send-email-erik.hugne@ericsson.com>
	 <20140305.235618.31002872977881096.davem@davemloft.net>
	 <20140306090634.GA6630@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GrADIjGaA7YTLc3RUFyQ"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, jon.maloy@ericsson.com,
	maloy@donjonn.com, ying.xue@windriver.com,
	paul.gortmaker@windriver.com, richard.alpe@ericsson.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51058 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751329AbaCIRsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 13:48:24 -0400
In-Reply-To: <20140306090634.GA6630@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GrADIjGaA7YTLc3RUFyQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 10:06 +0100, Erik Hugne wrote:
> On Wed, Mar 05, 2014 at 11:56:18PM -0500, David Miller wrote:
> > From: <erik.hugne@ericsson.com>
> > Date: Wed, 5 Mar 2014 08:56:13 +0100
> >=20
> > > @@ -413,8 +411,11 @@ int tipc_conn_sendmsg(struct tipc_server *s, int=
 conid,
> > >  	struct tipc_conn *con;
> > > =20
> > >  	con =3D tipc_conn_lookup(s, conid);
> > > -	if (!con)
> > > +	if (!con) {
> > > +		pr_err("Connection %d not found on server %s\n", conid,
> > > +		       s->name);
> > >  		return -EINVAL;
> > > +	}
> > > =20
> > >  	e =3D tipc_alloc_entry(data, len);
> > >  	if (!e) {
> >=20
> > You really don't want to add kernel log messages which might be easily
> > triggerable by the user.  Please remove this.
>=20
> Ok i'll remove it, but i'd anyway like to mention that this cannot be tri=
ggered
> by users. This function is only invoked from the TIPC internal services
> (subscriber and config) as a response from network events.

If 'network events' are triggered by packets received from remote hosts
or packets sent on behalf of arbitrary local users, then this is just as
bad.  You need to rate-limit such logging, usually by making it
conditional on net_ratelimit().

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-GrADIjGaA7YTLc3RUFyQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxypWee/yOyVhhEJAQrdwRAAsz3uEaXp2yI7ZPIw7jDXHgrPudcTOA+P
ldHSCHHuC/Kx5XWK0u8qjukKvrETjgqbkQbuS61TvRWFWmP4oCYLJ/i8hAtFcKQX
Z8vVBDSO46C01hsyNMFSqQoPl8RSxvgaqxzkHIXmQRrzh2mCYInQbxRRY1rgVxV5
APHz8FMZzBbvFCkX9KUZiD9stWU0FfDelAsTwnztA96Mmao6DKeG3RvIpVRKYQGr
NLEsAP+MhCZCme4wVsGspfT0RmmoGnQrrjOVm6jsRicml2mjhRyhoBvNArWxSWsl
LaoI53424cES2oVdFDFxgU8CFRkki+cY4SF5idA6XznQwawg2499bCSgBMTpzzNR
YD/4wDij0hG0by1g2FhPhMrBL/oGipK8IGzNp8/pg3W25/MGaPQhjy9MGniYa9WR
CcXziA7lYUjEYSejzQyfwM9tDZZWazj8WcB/yp9J7FrQnytaoTcKdoLKYtYlFfUO
ZbGkqJA8Ud+Hk4yOEsEozJxLCbbErafttugwT3Ism4OjWOdevnmn5ndkKKrIhnff
haGCpQ5OwPO6v6twivxdoMMquozkdNNlCkgQSBPot6D2/P/AoADQstgtduOOxImC
HyD9VDS/c3xgqBd/lhO0GrqClWuTUW+kSjUjMka5eVERYVMrW85MXzY4I4mi+oYo
fmqwND3RXMQ=
=AqGU
-----END PGP SIGNATURE-----

--=-GrADIjGaA7YTLc3RUFyQ--
