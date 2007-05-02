From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 2/2] ehea: NAPI multi queue TX/RX path for SMP
Date: Wed, 02 May 2007 14:59:43 +1000
Message-ID: <1178081983.5296.5.camel@concordia.ozlabs.ibm.com>
References: <200702281834.10856.ossthema@de.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-QHBAM+ndYevc28pSUDFh"
Cc: Jeff Garzik <jeff@garzik.org>, Thomas Klein <tklein@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58524 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992741AbXEBE7q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 00:59:46 -0400
In-Reply-To: <200702281834.10856.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-QHBAM+ndYevc28pSUDFh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-02-28 at 18:34 +0100, Jan-Bernd Themann wrote:
> This patch provides a functionality that allows parallel=20
> RX processing on multiple RX queues by using dummy netdevices.
>=20
>=20
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> ---

> @@ -1789,6 +1798,22 @@ static void ehea_xmit3(struct sk_buff *s
>  	dev_kfree_skb(skb);
>  }
> =20
> +static inline int ehea_hash_skb(struct sk_buff *skb, int num_qps)
> +{
> +	struct tcphdr *tcp;
> +	u32 tmp;
> +
> +	if ((skb->protocol =3D=3D htons(ETH_P_IP)) &&
> +	    (skb->nh.iph->protocol =3D=3D IPPROTO_TCP)) {

This breaks the build, looks like skb->nh went away:
b0e380b1d8a8e0aca215df97702f99815f05c094

/scratch/michael/kisskb-build/src/drivers/net/ehea/ehea_main.c:1806: error:=
 'struct sk_buff' has no member named 'nh'
/scratch/michael/kisskb-build/src/drivers/net/ehea/ehea_main.c:1807: error:=
 'struct sk_buff' has no member named 'nh'
/scratch/michael/kisskb-build/src/drivers/net/ehea/ehea_main.c:1807: error:=
 'struct sk_buff' has no member named 'nh'
/scratch/michael/kisskb-build/src/drivers/net/ehea/ehea_main.c:1809: error:=
 'struct sk_buff' has no member named 'nh'

cheers

--=20
Michael Ellerman
OzLabs, IBM Australia Development Lab

wwweb: http://michael.ellerman.id.au
phone: +61 2 6212 1183 (tie line 70 21183)

We do not inherit the earth from our ancestors,
we borrow it from our children. - S.M.A.R.T Person

--=-QHBAM+ndYevc28pSUDFh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGOBq/dSjSd0sB4dIRAiTPAKCVylILpeJAj70ItmUjBsd2icLayACeLoSq
43nBSFyiC/bKGGxIA8Uy6oE=
=AsQ6
-----END PGP SIGNATURE-----

--=-QHBAM+ndYevc28pSUDFh--

