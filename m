From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 net-next 1/2] ethtool - Support for configurable RSS
 hash key
Date: Sun, 23 Feb 2014 00:51:33 +0000
Message-ID: <1393116693.6823.31.camel@deadeye.wl.decadent.org.uk>
References: <1393069918-11539-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	 <ecb603ac-aefa-4288-9f90-c335b2faa6aa@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7JCn1D3/xMzvSQe4QlCl"
Cc: netdev@vger.kernel.org
To: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58495 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751982AbaBWAvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 19:51:41 -0500
In-Reply-To: <ecb603ac-aefa-4288-9f90-c335b2faa6aa@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7JCn1D3/xMzvSQe4QlCl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-02-22 at 17:21 +0530, Venkat Duvvuru wrote:
[...]
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -828,22 +828,30 @@ struct ethtool_rxnfc {
> =20
>=20
>  /**
> - * struct ethtool_rxfh_indir - command to get or set RX flow hash indire=
ction
> - * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFH=
INDIR
> - * @size: On entry, the array size of the user buffer, which may be zero=
.
> - *	On return from %ETHTOOL_GRXFHINDIR, the array size of the hardware
> - *	indirection table.
> - * @ring_index: RX ring/queue index for each hash value
> + * struct ethtool_rxfh - command to get or set RX flow hash indirection =
or/and
> + * hash key.
> + * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
> + * @indir_size: On entry, the array size of the user buffer, which may b=
e zero.
> + *		On return from %ETHTOOL_GRSSH, the array size of the hardware
> + *		indirection table.
> + * @key_size:	On entry, the array size of the user buffer in bytes,
> + *		which may be zero.
> + *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
> + * @rsvd:	Reserved for future extensions.
> + * @rss_config: RX ring/queue index for each hash value or/and hash key
> + *		respectively.
>   *
> - * For %ETHTOOL_GRXFHINDIR, a @size of zero means that only the size
> - * should be returned.  For %ETHTOOL_SRXFHINDIR, a @size of zero means
> - * the table should be reset to default values.  This last feature
> + * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that onl=
y the
> + * size should be returned.  For %ETHTOOL_SRSSH, a @indir_size of zero m=
eans
> + * the indir table should be reset to default values.  This last feature
>   * is not supported by the original implementations.
>   */
> -struct ethtool_rxfh_indir {
> -	__u32	cmd;
> -	__u32	size;
> -	__u32	ring_index[0];
> +struct ethtool_rxfh {
> +	__u32   cmd;
> +	__u32   indir_size;
> +	__u32   key_size;
> +	__u32	rsvd[3];
> +	__u32   rss_config[0];
>  };
>
>  /**
> @@ -1102,8 +1110,8 @@ enum ethtool_sfeatures_retval_bits {
>  #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device =
*/
>  #define ETHTOOL_GRXNTUPLE	0x00000036 /* deprecated */
>  #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
> -#define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table =
*/
> -#define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table =
*/
> +#define ETHTOOL_GRSSH		0x00000038 /* Get RX flow hash indir'n table */
> +#define ETHTOOL_SRSSH		0x00000039 /* Set RX flow hash indir'n table */
> =20
>  #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
>  #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings *=
/
[...]

You can't just redefine commands like this.  Think what will happen if
someone uses an old version of ethtool with a new kernel.

You have to keep supporting the old ethtool command numbers and
structure.  And you have to make the ethtool core keep working with all
the other drivers that don't support setting the key yet (or update them
so they do).

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names taken.

--=-7JCn1D3/xMzvSQe4QlCl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwlGFee/yOyVhhEJAQoEEg/7BwldRkLc9pzbjbexfp+oQOWCSKJSnaVA
uCpNHUbB5nJpKzlDeD7ju9015ZnZa2d3Nwnq6Xc0IF8MYEQYPhfM/WKtoLwWhZU4
7I4zou7tl71UuCIBYd5kOvxqqs7tWwDhTf5l3mVfiGLnO3SLjA/v/eS+kcEgwfcp
wSi0kuKyQGqRFAYSPELDoGXnmKybHZJGCoV3RbBT7tGkd+ZgcPHFqbaMLy8xgZY7
LcXLR8klQ1ArvgPk0BXYzYFaQOgTlenEwb2SGr+WlJ6d30DbJrTseG9Hm3OFxSm9
avBQV9bs2U1VW6nCz29KyQgTAKlcAPrsX9QXSJpo2vwSagAvp6HTgsn/gMO+2tXj
kwRazrWTO9qH3wSONZrDC5blCftsxI2doJ6nQzgQ0+eFLE0MFd/EiHDtGyFMWW8s
aDJ+tXddka8U9opYMB/ayLEjFHz9A9qC3lQrBmGiOO4YvB6m4OP/GVNizh+gEPBb
yH3027imLr29ra3K3XzSdxfazUzpCXfXEkv7m8cFvgmJ9h7cBodjn9ex0Kg7wHse
xH2uRjXlHXxs+kqIVjS6Djh2lPZqltE9K8Asc727zfsaR712bnSYFgXvrh5NYpK2
0fwVnbccAEQ8mohcDITkK8KpsLG2aZooEGk3ZdancE0nfmrHfYn7t6/0iMuUe718
hI0hFTqpmyo=
=18G1
-----END PGP SIGNATURE-----

--=-7JCn1D3/xMzvSQe4QlCl--
