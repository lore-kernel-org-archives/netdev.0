From: "Duda, Lukasz" <Lukasz.Duda@nordicsemi.no>
Subject: RE: [RFCv3 bluetooth-next 3/4] ipv6: add ipv6_addr_prefix_copy
Date: Tue, 1 Dec 2015 11:51:25 +0000
Message-ID: <AB80DA35A7B64E4E98291794926897D901164566B1@mbx06.nvlsi.no>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-4-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"mcr@sandelman.ca" <mcr@sandelman.ca>,
	"martin.gergeleit@hs-rm.de" <martin.gergeleit@hs-rm.de>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>
To: Alexander Aring <alex.aring@gmail.com>,
	"linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nordicsemi.no ([194.19.86.146]:38096 "EHLO
	ironport02.nordicsemi.no" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754895AbbLAMB1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 07:01:27 -0500
In-Reply-To: <1448796882-316-4-git-send-email-alex.aring@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Alexander Aring [mailto:alex.aring@gmail.com]
> Sent: Sunday, November 29, 2015 12:35
> To: linux-wpan@vger.kernel.org
> Cc: linux-bluetooth@vger.kernel.org; netdev@vger.kernel.org;
> kernel@pengutronix.de; mcr@sandelman.ca; Duda, Lukasz;
> martin.gergeleit@hs-rm.de; Alexander Aring; David S . Miller; Alexey
> Kuznetsov; James Morris; Hideaki YOSHIFUJI; Patrick McHardy
> Subject: [RFCv3 bluetooth-next 3/4] ipv6: add ipv6_addr_prefix_copy
>=20
> This patch adds a static inline function ipv6_addr_prefix_copy which =
copies a
> ipv6 address prefix(argument pfx) into the ipv6 address prefix.
> The prefix len is given by plen as bits. This function mainly based o=
n
> ipv6_addr_prefix which copies one address prefix from address into a =
new
> ipv6 address destination and zero all other address bits.
>=20
> The difference is that ipv6_addr_prefix_copy don't get a prefix from =
an
> ipv6 address, it sets a prefix to an ipv6 address with keeping other =
address
> bits. The use case is for context based address compression inside 6L=
oWPAN
> IPHC header which keeping ipv6 prefixes inside a context table to loo=
kup
> address-bits without sending them.
>=20
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>  include/net/ipv6.h | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>=20
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h index e1a10b0..c=
d3881e6
> 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -382,6 +382,21 @@ static inline void ipv6_addr_prefix(struct in6_a=
ddr
> *pfx,
>  		pfx->s6_addr[o] =3D addr->s6_addr[o] & (0xff00 >> b);  }
>=20
> +static inline void ipv6_addr_prefix_copy(struct in6_addr *addr,
> +					 const struct in6_addr *pfx,
> +					 int plen)
> +{
> +	/* caller must guarantee 0 <=3D plen <=3D 128 */
> +	int o =3D plen >> 3,
> +	    b =3D plen & 0x7;
> +
> +	memcpy(addr->s6_addr, pfx, o);
> +	if (b !=3D 0) {
> +		addr->s6_addr[o] &=3D ~(0xff00 >> b);
> +		addr->s6_addr[o] |=3D (pfx->s6_addr[o] & (0xff00 >> b));
> +	}
> +}
> +
>  static inline void __ipv6_addr_set_half(__be32 *addr,
>  					__be32 wh, __be32 wl)
>  {
> --
> 2.6.1

Acked-by: =A3ukasz Duda <lukasz.duda@nordicsemi.no>
