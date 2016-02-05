From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/2] ethtool: add IPv6 to the NFC API
Date: Fri, 05 Feb 2016 16:56:06 +0000
Message-ID: <1454691366.20702.61.camel@decadent.org.uk>
References: <56B483A1.4070901@solarflare.com>
	 <56B48485.4050707@solarflare.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vTZ5r2G+mPxS/QgXL+7p"
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38920 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754133AbcBEQ4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 11:56:15 -0500
In-Reply-To: <56B48485.4050707@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vTZ5r2G+mPxS/QgXL+7p
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-05 at 11:16 +0000, Edward Cree wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> =C2=A0include/uapi/linux/ethtool.h | 70 +++++++++++++++++++++++++++++++++=
+++++++----
> =C2=A01 file changed, 64 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index 57fa390..7faaf36 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -748,6 +748,56 @@ struct ethtool_usrip4_spec {
> =C2=A0	__u8=C2=A0=C2=A0=C2=A0=C2=A0proto;
> =C2=A0};
> =C2=A0
> +/**
> + * struct ethtool_tcpip6_spec - flow specification for TCP/IPv6 etc.
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @psrc: Source port
> + * @pdst: Destination port
> + * @tclass: Traffic Class
> + *
> + * This can be used to specify a TCP/IPv6, UDP/IPv6 or SCTP/IPv6 flow.
> + */
> +struct ethtool_tcpip6_spec {
> +	__be32	ip6src[4];
> +	__be32	ip6dst[4];
> +	__be16	psrc;
> +	__be16	pdst;
> +	__u8=C2=A0=C2=A0=C2=A0=C2=A0tclass;
> +};
> +
> +/**
> + * struct ethtool_ah_espip6_spec - flow specification for IPsec/IPv6
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @spi: Security parameters index
> + * @tclass: Traffic Class
> + *
> + * This can be used to specify an IPsec transport or tunnel over IPv6.
> + */
> +struct ethtool_ah_espip6_spec {
> +	__be32	ip6src[4];
> +	__be32	ip6dst[4];
> +	__be32	spi;
> +	__u8=C2=A0=C2=A0=C2=A0=C2=A0tclass;
> +};
> +
> +/**
> + * struct ethtool_usrip6_spec - general flow specification for IPv6
> + * @ip6src: Source host
> + * @ip6dst: Destination host
> + * @l4_4_bytes: First 4 bytes of transport (layer 4) header
> + * @tclass: Traffic Class
> + * @l4_proto: Transport protocol number (nexthdr after any Extension Hea=
ders)
> + */
> +struct ethtool_usrip6_spec {
> +	__be32	ip6src[4];
> +	__be32	ip6dst[4];
> +	__be32	l4_4_bytes;
> +	__u8=C2=A0=C2=A0=C2=A0=C2=A0tclass;
> +	__u8=C2=A0=C2=A0=C2=A0=C2=A0l4_proto;
> +};
> +
> =C2=A0union ethtool_flow_union {
> =C2=A0	struct ethtool_tcpip4_spec		tcp_ip4_spec;
> =C2=A0	struct ethtool_tcpip4_spec		udp_ip4_spec;
> @@ -755,6 +805,12 @@ union ethtool_flow_union {
> =C2=A0	struct ethtool_ah_espip4_spec		ah_ip4_spec;
> =C2=A0	struct ethtool_ah_espip4_spec		esp_ip4_spec;
> =C2=A0	struct ethtool_usrip4_spec		usr_ip4_spec;
> +	struct ethtool_tcpip6_spec		tcp_ip6_spec;
> +	struct ethtool_tcpip6_spec		udp_ip6_spec;
> +	struct ethtool_tcpip6_spec		sctp_ip6_spec;
> +	struct ethtool_ah_espip6_spec		ah_ip6_spec;
> +	struct ethtool_ah_espip6_spec		esp_ip6_spec;
> +	struct ethtool_usrip6_spec		usr_ip6_spec;
> =C2=A0	struct ethhdr				ether_spec;
> =C2=A0	__u8					hdata[52];
> =C2=A0};
> @@ -1367,15 +1423,17 @@ enum ethtool_sfeatures_retval_bits {
> =C2=A0#define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
> =C2=A0#define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
> =C2=A0#define	AH_ESP_V4_FLOW	0x04	/* hash only */
> -#define	TCP_V6_FLOW	0x05	/* hash only */
> -#define	UDP_V6_FLOW	0x06	/* hash only */
> -#define	SCTP_V6_FLOW	0x07	/* hash only */
> +#define	TCP_V6_FLOW	0x05	/* hash or spec (tcp_ip6_spec; nfc only) */
> +#define	UDP_V6_FLOW	0x06	/* hash or spec (udp_ip6_spec; nfc only) */
> +#define	SCTP_V6_FLOW	0x07	/* hash or spec (sctp_ip6_spec; nfc only) */
> =C2=A0#define	AH_ESP_V6_FLOW	0x08	/* hash only */
> =C2=A0#define	AH_V4_FLOW	0x09	/* hash or spec (ah_ip4_spec) */
> =C2=A0#define	ESP_V4_FLOW	0x0a	/* hash or spec (esp_ip4_spec) */
> -#define	AH_V6_FLOW	0x0b	/* hash only */
> -#define	ESP_V6_FLOW	0x0c	/* hash only */
> -#define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
> +#define	AH_V6_FLOW	0x0b	/* hash or spec (ah_ip6_spec; nfc only) */
> +#define	ESP_V6_FLOW	0x0c	/* hash or spec (esp_ip6_spec; nfc only) */
> +#define	IPV4_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
> +#define	IP_USER_FLOW	IPV4_USER_FLOW
> +#define	IPV6_USER_FLOW	0x0e	/* spec only (usr_ip6_spec; nfc only) */
> =C2=A0#define	IPV4_FLOW	0x10	/* hash only */
> =C2=A0#define	IPV6_FLOW	0x11	/* hash only */
> =C2=A0#define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
>=20
--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein
--=-vTZ5r2G+mPxS/QgXL+7p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVrTUJue/yOyVhhEJAQrRTA/+LbMleDvsMZFMYRG5E32DuxuDBFHWxq7j
2lItdnoT/Krh/IlOM1gjIQ8w2kXucbZAENI7iwCfZ3RhPW97oV07h2cpSr27YH5Y
cpDJNp5/QmsWTdZL4O9vtgHGx+3avnkbZ+ZzmQKKNNoaE3LeFlYY2/FNRnZmZBt4
DPoI15saMPzRPtYbMFyXxUagYQFp6QAUew+bt1Uu94H4uuvyGV2ruAOdPztCWNw4
VDioLOTtqcTF8A3xb2jxfrCpxGej2Bb55S45lSZmD+Ibl1DU/IKVL2PrpwlU/T6S
v5sw15rMCwlt4WBoM1uunAC3yeXtOotuebCfmrN0B27DHDOgZQqQgW/kRtmT8bHv
kW9F23EEoMBdnncwpzZUtuI8pwF9O10UdzHZMaMvLq6XWGH/R7b6uHlsCyGIb85O
aidKh3p42DOH6YOKV5UQXUVMCqY6oeiybYe1N002LLEhLiuTQQmgDZs9+aBUCCFR
nqhr6lwoM8f9Hnxl6A1aVGZ6kvVPHkJa+szH8g02RYojjXYvLFuo0FW8Rri0F6MM
Ac+g0fVPmILb8rTtTSkEkCgJgkA5p37tOc4li5OX5d8HevhN0GfevmXH0EVqUyCZ
6Z2V6TGGJr5oQJtUQtq4MlAfVe5acPI2iGKpWWa2SCbpQmyBFvRZwqvK3BXU8RTg
tlpi6GODkCk=
=ZFl8
-----END PGP SIGNATURE-----

--=-vTZ5r2G+mPxS/QgXL+7p--
