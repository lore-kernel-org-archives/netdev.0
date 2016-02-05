From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] sfc: implement IPv6 NFC (and
 IPV4_USER_FLOW)
Date: Fri, 05 Feb 2016 01:47:34 +0000
Message-ID: <1454636854.20702.16.camel@decadent.org.uk>
References: <56B0F9A8.7010202@solarflare.com>
	 <56B0FA53.2040405@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/yITti4TA2eaqHZRODbn"
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35530 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750736AbcBEBrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 20:47:46 -0500
In-Reply-To: <56B0FA53.2040405@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/yITti4TA2eaqHZRODbn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-02 at 18:49 +0000, Edward Cree wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
> =C2=A0drivers/net/ethernet/sfc/ethtool.c | 176 ++++++++++++++++++++++++++=
+++++++++++
> =C2=A01 file changed, 176 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sf=
c/ethtool.c
> index 0347976..49fac36 100644
> --- a/drivers/net/ethernet/sfc/ethtool.c
> +++ b/drivers/net/ethernet/sfc/ethtool.c
[...]
> =C2=A0static int efx_ethtool_get_class_rule(struct efx_nic *efx,
> =C2=A0				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_rx_flow_spec=
 *rule)
> =C2=A0{
[...]
> @@ -855,6 +896,39 @@ static int efx_ethtool_get_class_rule(struct efx_nic=
 *efx,
> =C2=A0			mac_entry->h_proto =3D spec.ether_type;
> =C2=A0			mac_mask->h_proto =3D ETHER_TYPE_FULL_MASK;
> =C2=A0		}
> +	} else if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE &&
> +		=C2=A0=C2=A0=C2=A0spec.ether_type =3D=3D htons(ETH_P_IP)) {

Shouldn't this also check that no unhandled match flags are set?

> +		rule->flow_type =3D IPV4_USER_FLOW;
> +		uip_entry->ip_ver =3D ETH_RX_NFC_IP4;
> +		if (spec.match_flags & EFX_FILTER_MATCH_IP_PROTO) {
> +			uip_mask->proto =3D IP_PROTO_FULL_MASK;
> +			uip_entry->proto =3D spec.ip_proto;
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_LOC_HOST) {
> +			uip_entry->ip4dst =3D spec.loc_host[0];
> +			uip_mask->ip4dst =3D IP4_ADDR_FULL_MASK;
> +		}
> +		if (spec.match_flags & EFX_FILTER_MATCH_REM_HOST) {
> +			uip_entry->ip4src =3D spec.rem_host[0];
> +			uip_mask->ip4src =3D IP4_ADDR_FULL_MASK;
> +		}
> +	} else if (spec.match_flags & EFX_FILTER_MATCH_ETHER_TYPE &&
> +		=C2=A0=C2=A0=C2=A0spec.ether_type =3D=3D htons(ETH_P_IPV6)) {

Same here.

[...]
> =C2=A0static int efx_ethtool_set_class_rule(struct efx_nic *efx,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0struct ethtool_rx_flow_spec *rule)
> =C2=A0{
[...]
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0case IPV6_USER_FLOW:
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0if (uip6_mask-&gt;l4_4_bytes || uip6_mask-&gt;tos)
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0return -E=
INVAL;
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0spec.match_flags =3D EFX_FILTER_MATCH_ETHER_TYPE;
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0spec.ether_type =3D htons(ETH_P_IPV6);
> +		if (!ip6_mask_is_empty(ip6_mask->ip6dst)) {

This should use uip6_mask not ip6_mask.

> +			if (!ip6_mask_is_full(uip6_mask->ip6dst))
> +				return -EINVAL;
> +			spec.match_flags |=3D EFX_FILTER_MATCH_LOC_HOST;
> +			memcpy(spec.loc_host, uip6_entry->ip6dst, sizeof(spec.loc_host));
> +		}
> +		if (!ip6_mask_is_empty(ip6_mask->ip6src)) {
[...]

Same here.

Ben.

--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein
--=-/yITti4TA2eaqHZRODbn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVrP/Nue/yOyVhhEJAQqT/RAA0Fwhf4dRJvHz3tWLhpbGFnc2+DSE/9qu
8QS5uOFLrBOIbniTYkAsF6+VpIrs5Z7/CszmFU6aRe9w0s7BpVMvDcaaWlNVgSrk
2thMZKSytagcKZKJuse4Jesow5j6ozYtcKZxMesFNUTGtppzWtrAit06r9WXb58U
d7nwMA/nmHrhbJbhqtxXe1H7Mjfd9OvVJwvy221MvPL+HZ7Lg3hc/3wojZXh8N/T
kc5a/X67zEW7I3SJ0qO5fhPHddRsdB3NAcNX9sqy5YN4lJa+6kgfJ4nZ7jK+101x
Oer2soTLtnk+cb+PKYW0OwgccUCVakn/VjvstZRHzG8jmneEJTmd1CfIdxE5XkqI
zfdirotdqO7jpI2B8ZL2Xw0GjgY9a//NJf9wh/gKKv6ZhvewRLMXTJexspDiwF7m
nsVAYv7M5AJAOjbE/30nd9lyqsbuULILnuuSp4B6QYHCZLEtv7qQtp3Bj+6iTuPp
DEUsrjknoyxHs0+78y8kzhlsMlZ5tLrVTqzbEuJP2ThYQAI6rZzEvnkOhJTdOvcP
cdWm3CzYEHwLaCOiOgqpBXWdF9NROOFEaP4cBc8cMizljoxhXlW9ngJCeqaAWIU/
FPcWYgvU1yrKSZJ7Q/FVZHTJlwmwQ/eNiRq5rNU7HaklsBlPPncqt/PHOzWhtJET
OizFBND9Oa0=
=q0jY
-----END PGP SIGNATURE-----

--=-/yITti4TA2eaqHZRODbn--
