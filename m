From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH 2/2] net: ethernet: renesas: sh_eth: don't open code
 of_device_get_match_data()
Date: Wed, 2 Mar 2016 07:46:24 +0100
Message-ID: <20160302064623.GA1403@katana>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
 <1456850284-8336-2-git-send-email-wsa@the-dreams.de>
 <20160302012134.GB32543@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160302012134.GB32543@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 02, 2016 at 10:21:34AM +0900, Simon Horman wrote:
> On Tue, Mar 01, 2016 at 05:37:59PM +0100, Wolfram Sang wrote:
> > From: Wolfram Sang <wsa+renesas@sang-engineering.com>
> >=20
> > This change will also make Coverity happy by avoiding a theoretical NULL
> > pointer dereference; yet another reason is to use the above helper func=
tion
> > to tighten the code and make it more readable.
> >=20
> > Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
> > ---
> >=20
> > Tested on a Lager board.
> >=20
> >  drivers/net/ethernet/renesas/sh_eth.c | 10 +++-------
> >  1 file changed, 3 insertions(+), 7 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethern=
et/renesas/sh_eth.c
> > index 0a150b2289146f..8b6c07fe3d407d 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -3056,15 +3056,11 @@ static int sh_eth_drv_probe(struct platform_dev=
ice *pdev)
> >  	mdp->ether_link_active_low =3D pd->ether_link_active_low;
> > =20
> >  	/* set cpu data */
> > -	if (id) {
> > +	if (id)
> >  		mdp->cd =3D (struct sh_eth_cpu_data *)id->driver_data;
> > -	} else	{
> > -		const struct of_device_id *match;
> > +	else
> > +		mdp->cd =3D (struct sh_eth_cpu_data *)of_device_get_match_data(&pdev=
->dev);
>=20
> Is the cast needed here? of_device_get_match_data returns void *

The compiler complains about a const mismatch without the cast. To keep
things simple, I decided to leave the cast.


--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJW1ow/AAoJEBQN5MwUoCm2UAIP/jPj5QFZXpFg1l9wp0euRX86
UjP05L6CPTvm69vh33Dz2THa174kVsq2L1AmfDfIgHs1gLIInUH8iRLCh2M2OS6g
V6aorFjsAHX6Eed8x4wuORnyzLdbEWtnzPFLhbos4CgwKDfPtjGpVR/kwvDPZWkB
sCI9f8AVf5Y6TkxjPD0od/vV6FzbiIi/js3yl1sn/qK8mezj6SFxPiAuZcr9gfd8
w8yurTt0zAycOg8pt+gknf7O9vN+t7aQ2jxeVbM6BtSDadtDEpMtYS+GufHag+Ue
aVUTo/cqVVzQ0ijsf2DbDARjfzoFioU9Vk3HE/NJg2cAl3FqRKKHeS2RwGWj43MX
hn6YkqPFEFAuoRcmq3Eoz0BZlKMxJNsADAlWVTzJc3kTbn4W2c52ewpCwx8O9ev8
Sr/JsWDZD4IrtkjYJiW/PGu/0NihEKhuEgEwWiLhPhdkXDFLjXlv/EVIz8C6YERZ
CtztZfZyF4DluZ9Lf+TJtQ1C8fTzFd59I6viW/KYASlPtajoZKYkg6xAiqxwSSUn
21D+Z3xUpP/4J7EPjyv76RsOedR3jW2jaI/KOymACn/WHED7F6u5SV6nt4Y04I2F
I5i1CFIwR+NHULbsB+h0WQDjpShGW6vaetE147EXEnfMsYphYWONkRgoW694uO2c
tpckHCmxYq356Uk5xvm8
=ynAQ
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
