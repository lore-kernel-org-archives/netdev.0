From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: [BUG] icmpv6fuzz creates bad paging request
Date: Fri, 2 Jan 2009 11:28:20 +0100
Message-ID: <20090102102820.GA6088@alice>
References: <20090101201304.GA6698@alice> <Pine.LNX.4.64.0901021040050.6207@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:33448 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756208AbZABK2Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 05:28:25 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901021040050.6207@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

* Ilpo J=C3=A4rvinen (ilpo.jarvinen@helsinki.fi) wrote:
> On Thu, 1 Jan 2009, Eric Sesterhenn wrote:
>=20
> > Hi,
> >=20
> > running "icmpv6fuzz -r 2187" gives me the following oops with curre=
nt -git
>=20
> Can you try the patch below.
>=20
> I wonder btw what's the correct policy wrt. those optval =3D=3D NULL =
checks=20
> that's visible in the patch' context (IPV6_PKTINFO is the only one wh=
ich
> is doing that while many there fetch to sizeof(struct something)).

patch works for me, thanks for the fast reply.

Greetings, Eric

> [PATCH] ipv6: IPV6_PKTINFO relied userspace providing correct length
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Reported-by: Eric Sesterhenn <snakebyte@gmx.de>
> ---
>  net/ipv6/ipv6_sockglue.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 0069b7e..d31df0f 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -403,7 +403,7 @@ sticky_done:
>  		else if (optlen < sizeof(struct in6_pktinfo) || optval =3D=3D NULL=
)
>  			goto e_inval;
> =20
> -		if (copy_from_user(&pkt, optval, optlen)) {
> +		if (copy_from_user(&pkt, optval, sizeof(struct in6_pktinfo))) {
>  				retv =3D -EFAULT;
>  				break;
>  		}
