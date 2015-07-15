From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: "ss -p" segfaults
Date: Wed, 15 Jul 2015 16:49:38 +0000
Message-ID: <E7D9D05A-8C76-43A4-AF2F-B64C27E6C20B@intel.com>
References: <2282663.K45lFmE7Zp@fb07-iapwap2>
 <20150715151204.GB28525@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_32F8F589-B6EE-48E5-98D1-CA285BE7DEC1";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Marc Dietrich <marvin24@gmx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36400 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbbGOQtp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 12:49:45 -0400
In-Reply-To: <20150715151204.GB28525@angus-think.wlc.globallogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_32F8F589-B6EE-48E5-98D1-CA285BE7DEC1
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Jul 15, 2015, at 8:12 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> Would you please check this fix ?
>=20
> diff --git a/misc/ss.c b/misc/ss.c
> index 03f92fa..3a826e4 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -683,8 +683,8 @@ static inline void sock_addr_set_str(inet_prefix =
*prefix, char **ptr)
>=20
> static inline char *sock_addr_get_str(const inet_prefix *prefix)
> {
> -    char *tmp ;
> -    memcpy(&tmp, prefix->data, sizeof(char *));
> +    char *tmp;
> +    memcpy(&tmp, &prefix->data[0], sizeof(char *));
>     return tmp;
> }

That surely is not a fix! The destination of the memcpy is the address =
of an uninitialized stack variable! Both versions are equally bad.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_32F8F589-B6EE-48E5-98D1-CA285BE7DEC1
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVpo8hAAoJEDwO/+eO4+5uIfUQAL1fiVED0YDNhZ1YBhELlT28
HPbP1ijuiJnirmYlRM771lAc/hiH7TE9QMKAmWzuXiVirgd6P/czUqGe5xOLTw1q
FrY5P7+0ztVeR64z/gDErkXRrRCkNyRzXDBJWbU/ttQmV1nDfCPoJtsEhS2uB5bm
fh9nzzsVi/YYzx3M0GhOTcAbChw5PYL8smF8mG5D+k+K6Xj7cohap4SBUA3Hec6W
oh+LSe/G/1x2RIKMmmdhmsIvZvU4XgbgnZ1EvmgzFmNVilKQt+uj3H5dgw025QFX
jIEzw1diKkfUdciMMCq9h0mr76M4abQ+HorH5q/SRfr5Eo8G9Yio6fjKoqD/MbQm
Zf1oX4S2qAK3B2CZE6NPuQtc+Ydu/bT9L0CdWsdSrijctKuU36HZUccMWdTCrEDY
veBo3c6dXRiJLTichRspw4yMCeP/y+nP3WK6qlq6OkJtt9/RVjoPg6udlI1ZlR9u
Y0y7TUan9neQwxjuVXgTUbt3AhHqGi1jHr8Su+06/2wbCh9xQXL4Q9TMkQscZ0PA
whfhCXnJGL1jaYIRDdzL2rgp29zxjvjTt0Cc2eC3trZT4yxS12nszmkt6K3H6rV6
OKdy1y12hNXiHTszv33SLXNAgaebj/NOghmuH1murO9+kugYk539K4FvYEutwOyb
ibpdsmijungRv84Ip1/K
=68Gw
-----END PGP SIGNATURE-----

--Apple-Mail=_32F8F589-B6EE-48E5-98D1-CA285BE7DEC1--
