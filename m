From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 01/11] i40e: only warn once of PTP nonsupport in
 100Mbit speed
Date: Tue, 18 Nov 2014 01:33:40 -0800
Message-ID: <1416303220.2295.19.camel@jtkirshe-mobl>
References: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416302731-11327-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-b7o8nJZbJAOTqWKkwE4H"
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net, Joe Perches <josephx.perches@intel.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39157 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140AbaKRJdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 04:33:42 -0500
In-Reply-To: <1416302731-11327-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-b7o8nJZbJAOTqWKkwE4H
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-18 at 01:25 -0800, Jeff Kirsher wrote:
> From: Shannon Nelson <shannon.nelson@intel.com>
>=20
> Only warn once that PTP is not supported when linked at 100Mbit.
>=20
> Yes, using a static this way means that this once-only message is not
> port specific, but once only for the life of the driver, regardless of
> the number of ports.  That should be plenty.
>=20
> Change-ID: Ie6476530056df408452e195ef06afd4f57caa4b2
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ptp.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)

Florian/Joe-

Since your patch to update the dev_level_once() function is going
through Greg KH's tree, we will stick with this patch until it gets
accepted and merged into Dave's tree.  Then we will provide a patch to
update the driver.

>=20
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/eth=
ernet/intel/i40e/i40e_ptp.c
> index 537b621..f9151037 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> @@ -382,11 +382,17 @@ void i40e_ptp_set_increment(struct i40e_pf *pf)
>  		incval =3D I40E_PTP_1GB_INCVAL;
>  		break;
>  	case I40E_LINK_SPEED_100MB:
> -		dev_warn(&pf->pdev->dev,
> -			 "%s: 1588 functionality is not supported at 100 Mbps. Stopping the P=
HC.\n",
> -			 __func__);
> +	{
> +		static int warn_once;
> +
> +		if (!warn_once) {
> +			dev_warn(&pf->pdev->dev,
> +				 "1588 functionality is not supported at 100 Mbps. Stopping the PHC.=
\n");
> +			warn_once++;
> +		}
>  		incval =3D 0;
>  		break;
> +	}
>  	case I40E_LINK_SPEED_40GB:
>  	default:
>  		incval =3D I40E_PTP_40GB_INCVAL;


--=-b7o8nJZbJAOTqWKkwE4H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUaxJ0AAoJEOVv75VaS+3OeuUP/il7asLkH+8Z6NJuuDpSBZCl
j7huW/fPAZB/WBl8veschHUfutqDGQKxwGpfuzCeaHYYOgLfQxevwlOmh6IwenbE
WmD8MPznFFWPAr+IUWVs1N1AuGe8obQ9eojeBPH+2agGRBdk1P9Yesx+urpRmN1F
ba8vPhHMQ0QR1xODOKRVzIFUfEHgWjBPfHD0aNfFB/jJVTMOPfJGQX4px6iSlcO2
IbkXoOxCwvLt65pw/NpyngwwJ5KA8PJAQcRoptsZ4kP9MgcmOLaVrvrjrd9cY9LZ
sslresB3M2LhkZbX6k/WbzDgLVTkhV2PcqoFTXZa0UKxThdwy3oN06lz27/A99Re
mEn1jv9yJPnLoyq1p7nGuctBV0oXvcnntzivB3TZEFEUpTi93aY3o3Knaco1iiJw
xqEI9D/zTFualuyvHtQaStxKV0jA9F+hJlC0x0XL2Ur8bEU/CCblpLciZ97VSeat
9P3KdKLp/E3flpZub5eiCJqYKsp3d+LUGH0XDp2pTQ7SiyG+LbjPvsp20BlFM9vu
8yp5KuLUu+236xHVdG2+AYNbXtw3g3dJOin84VqQl1SuN5RO2aBpltSfb8f2XWeg
ZMGHNso94fXnlIe9xfsejlLehHuihQ1M3Up7zC/4IghxZL0wuy95YpeFKCYgs5hq
6h/uwWWtJRdxBXbF9d6X
=agC+
-----END PGP SIGNATURE-----

--=-b7o8nJZbJAOTqWKkwE4H--
