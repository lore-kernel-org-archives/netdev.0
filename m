From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC v2 1/1] net: Add support to configure SR-IOV VF minimum
 and maximum Tx rate through ip tool.
Date: Mon, 24 Mar 2014 18:55:00 +0000
Message-ID: <1395687300.2832.37.camel@deadeye.wl.decadent.org.uk>
References: <1395637073-29794-1-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1395637073-29794-2-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ufrVdjkZh/NUGMhQh8k9"
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com,
	gregory.v.rose@intel.com, linux-net-drivers@solarflare.com,
	Ariel.Elior@qlogic.com, amirv@mellanox.com, mkubecek@suse.cz
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44088 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753583AbaCXSzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 14:55:17 -0400
In-Reply-To: <1395637073-29794-2-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ufrVdjkZh/NUGMhQh8k9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-24 at 00:57 -0400, Sucheta Chakraborty wrote:
[...]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
[...]
> +		case IFLA_VF_RATE: {
> +			struct ifla_vf_rate *ivt;
> +			struct ifla_vf_info ivf;
>  			ivt =3D nla_data(vf);
>  			err =3D -EOPNOTSUPP;
> -			if (ops->ndo_set_vf_tx_rate)
> -				err =3D ops->ndo_set_vf_tx_rate(dev, ivt->vf,
> -							      ivt->rate);
> +			if ((ivt->min_tx_rate =3D=3D -1 ||
> +			     ivt->max_tx_rate =3D=3D -1) &&
> +			    ops->ndo_get_vf_config)
> +				err =3D ops->ndo_get_vf_config(dev, ivt->vf,
> +							     &ivf);
> +			else
> +				err =3D 0;
> +			if (err)
> +				break;
> +			if (ivt->min_tx_rate =3D=3D -1)
> +				ivt->min_tx_rate =3D ivf.min_tx_rate;
> +			if (ivt->max_tx_rate =3D=3D -1)
> +				ivt->max_tx_rate =3D ivf.max_tx_rate;
[...]

This is modifying the the content of the netlink skb, which I think is
not allowed.  I think you need to use local variables for this instead.

Also, this special-casing of -1 isn't documented anywhere.  Is it even
necessary?  If userland needs to set just one limit, it can read the
existing limits and set both.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-ufrVdjkZh/NUGMhQh8k9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzB/hOe/yOyVhhEJAQpg2g//TvuJ21cz3VnKV2BWXNotwrUkB1K5hTqw
TfSnrtO8HeFBU9VmNTc7WzmEFHnVtMrPc3GtNL0ROtABmUMFbv+BSlO43AjxaZTV
9D9PtuHql4tYhe7/4CsYajDMLQF/tjEwHPMeP9yNRYSDjnWlHcAgD2q0zaNlJonV
AEkpGOBnF3Slno96ifsOfNEn7p+imXWdJnu4eJsFvLDjWYTPFoMoQe/FUYVOievv
w6eWQfXitTE3/LNJ2mBtYtNBD+1JY78W4iY4KGrmXORzbTFDuWykaWO8iBiLcgy/
ztA5g4EUAYm3r90KR9dkBQVJqJ40pr+8SVV7pqC/+ffJCFwIBxW3VP1iDHURR/Ir
aDF8FMLTYYQDSZ76DQfjLnPH8OIMSvl9bznTNdMzAL6l7n1jqb6ibYuJbi8uJltY
YHzT/7fQrWualspFLXc6hWjikisn5DkKVdRnMDssh5vfvW0qrpVVY35geg4KICC0
cZ7cXctL9Wxzv4Dz0bkRGpAcqaM989cgbJB1Db5zCc15eOE2NAmZYYZbOjyfrcgQ
SbK7Pscl9If8xrRx+8wswlhkmWZSwVrK/Zg8okbzpas2yQQC3LRHA2VM+1q4VQ13
LssN5Gay0SaYzIRryCOs+sHJLTKAJ3v52VACppgF5Jggo+Fj82gxDbf9iRtC15hC
Un5DspCL5A0=
=kNVK
-----END PGP SIGNATURE-----

--=-ufrVdjkZh/NUGMhQh8k9--
