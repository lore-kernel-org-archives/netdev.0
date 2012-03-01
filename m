From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size parametre.
Date: Thu, 1 Mar 2012 14:37:36 +0300
Message-ID: <20120301113736.GE22598@mwanda>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
 <20120301101809.GA6488@1984>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2hMgfIw2X+zgXrFs"
Cc: santosh nayak <santoshprasadnayak@gmail.com>,
	bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120301101809.GA6488@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2hMgfIw2X+zgXrFs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 01, 2012 at 11:18:09AM +0100, Pablo Neira Ayuso wrote:
> On Thu, Mar 01, 2012 at 02:46:30PM +0530, santosh nayak wrote:
> > From: Santosh Nayak <santoshprasadnayak@gmail.com>
> >=20
> > While copying to userspace, the size of source is 29byte where as
> > size parametre is 32 byte.  Its leaking extra-information from
> > kernel space to user space.
> > Replace EBT_FUNCTION_MAXNAMELEN by XT_EXTENSION_MAXNAMELEN.
>=20
> There's no information leak.
>=20

Where do we clear "m"?=20

include/linux/netfilter/x_tables.h
   287  struct xt_match {
   288          struct list_head list;
   289 =20
   290          const char name[XT_EXTENSION_MAXNAMELEN];
   291          u_int8_t revision;
   292 =20

There is a 2 byte holes here between "revision" and "match()".  We
copy three bytes past the end of name, so we include revision and
the hole.

But maybe we memset it somewhere?  I'm not sure.

   293          /* Return true or false: return FALSE and set *hotdrop =3D =
1 to
   294             force immediate packet drop. */
   295          /* Arguments changed since 2.6.9, as this must now handle
   296             non-linear skb, using skb_header_pointer and
   297             skb_ip_make_writable. */
   298          bool (*match)(const struct sk_buff *skb,
   299                        struct xt_action_param *);

regards,
dan carpenter


--2hMgfIw2X+zgXrFs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPT1+AAAoJEOnZkXI/YHqRKx4P/RanpcSe0yquG5PCGH83USUS
ZQ9KYI5y1ZPBi6wYwtX9MHRssH1/JQeGty/94HUhxrNbwwpppvAcbpZT5xCffV3u
EHFHWX++wO8oIp3as2pKBZuQ7TYlJz+zLsgmV5+QhvCuD50QaKS1R6zfzRERiFIA
8Xp5rW5b44viORHWFZaZ7rOqjRABIpTlrfTC9Wkg0Oste/1nq5tRXGqvOZPudNmp
XlXprGMcC8pvWAu+U8iAIDv/SFwkJazcKCBVA7VN62V0VIRSup8NbvL/La65R8EG
vnxUhOIkxAYv6y0nByUuCs7cHT/LMq/AQgHVgFrtNF0LZNPD9XivjfzkKOz5I30C
dNk0GnnfuxmJfNCupSfngh8IUbTM46eNd0O15DiPZSuOhEmvEjji+oS0ZQg3cWFg
lryoLZh0Oq1EJ9mllfmuixYHu3XeIK4dM7tU9l8qZIv7jjiRWrKOwo6vL9ip862O
G3072/114Cpr/4kK3k7msObKH//+GgRlqBRnvOaxADTWCWnGpcRdOFvcfBvoJFGI
6f46TQTNhS7YYtPuARrMMt8CW2pQouKYZ94N8ShocHYYANA247EIiCCYlpbXg8aX
cC9YtY8bguDyJ/6fC4wJGOpOqbqTJqYw6sFWccydz79LJ39bBDNfBjf9jMzPWWSV
DkI0tbloqsX3HAP/yN9+
=RUds
-----END PGP SIGNATURE-----

--2hMgfIw2X+zgXrFs--
