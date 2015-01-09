From: William Dauchy <william@gandi.net>
Subject: Re: [PATCH iproute2] ip link: Fix crash on older kernels when show
 VF dev
Date: Fri, 9 Jan 2015 18:55:57 +0100
Message-ID: <20150109175557.GF31810@gandi.net>
References: <1420824351-23450-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/i8j2F0k9BYX4qLc"
Cc: netdev@vger.kernel.org, william@gandi.net
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:52095 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750976AbbAISBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2015 13:01:48 -0500
Content-Disposition: inline
In-Reply-To: <1420824351-23450-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/i8j2F0k9BYX4qLc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Jan09 19:25, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>=20
> The issue was caused that ifla_vf_rate does not exist on
> older kernels and should be checked if it exists as nested attr.
>=20
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> Reported-by: William Dauchy <william@gandi.net>
> Tested-by: William Dauchy <william@gandi.com>

gandi.net actually ;)

Thanks,

> ---
>  ip/ipaddress.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
>=20
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 28dfe8c..830b166 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -259,11 +259,10 @@ static void print_vfinfo(FILE *fp, struct rtattr *v=
finfo)
>  {
>  	struct ifla_vf_mac *vf_mac;
>  	struct ifla_vf_vlan *vf_vlan;
> -	struct ifla_vf_rate *vf_rate;
>  	struct ifla_vf_tx_rate *vf_tx_rate;
>  	struct ifla_vf_spoofchk *vf_spoofchk;
>  	struct ifla_vf_link_state *vf_linkstate;
> -	struct rtattr *vf[IFLA_VF_MAX+1];
> +	struct rtattr *vf[IFLA_VF_MAX + 1] =3D {};
>  	struct rtattr *tmp;
>  	SPRINT_BUF(b1);
> =20
> @@ -277,7 +276,6 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfi=
nfo)
>  	vf_mac =3D RTA_DATA(vf[IFLA_VF_MAC]);
>  	vf_vlan =3D RTA_DATA(vf[IFLA_VF_VLAN]);
>  	vf_tx_rate =3D RTA_DATA(vf[IFLA_VF_TX_RATE]);
> -	vf_rate =3D RTA_DATA(vf[IFLA_VF_RATE]);
> =20
>  	/* Check if the spoof checking vf info type is supported by
>  	 * this kernel.
> @@ -313,10 +311,16 @@ static void print_vfinfo(FILE *fp, struct rtattr *v=
finfo)
>  		fprintf(fp, ", qos %d", vf_vlan->qos);
>  	if (vf_tx_rate->rate)
>  		fprintf(fp, ", tx rate %d (Mbps)", vf_tx_rate->rate);
> -	if (vf_rate->max_tx_rate)
> -		fprintf(fp, ", max_tx_rate %dMbps", vf_rate->max_tx_rate);
> -	if (vf_rate->min_tx_rate)
> -		fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
> +
> +	if (vf[IFLA_VF_RATE]) {
> +		struct ifla_vf_rate *vf_rate =3D RTA_DATA(vf[IFLA_VF_RATE]);
> +
> +		if (vf_rate->max_tx_rate)
> +			fprintf(fp, ", max_tx_rate %dMbps", vf_rate->max_tx_rate);
> +		if (vf_rate->min_tx_rate)
> +			fprintf(fp, ", min_tx_rate %dMbps", vf_rate->min_tx_rate);
> +	}
> +
>  	if (vf_spoofchk && vf_spoofchk->setting !=3D -1) {
>  		if (vf_spoofchk->setting)
>  			fprintf(fp, ", spoof checking on");
> --=20
> 2.1.3
>=20

--=20
William

--/i8j2F0k9BYX4qLc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlSwFi0ACgkQ1I6eqOUidQHp+QCbBZIEWCkP6HEgLrvYJb0M2ZdA
K3MAoJY0orpHIWqJAdw0BNEUmOJiutD0
=wmOs
-----END PGP SIGNATURE-----

--/i8j2F0k9BYX4qLc--
