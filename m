From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Simplify SA looking up when using
 wildcard source address
Date: Tue, 24 Sep 2013 13:45:51 +0200
Message-ID: <20130924114551.GT7660@secunet.com>
References: <1379927917-17365-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59456 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab3IXLpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:45:55 -0400
Content-Disposition: inline
In-Reply-To: <1379927917-17365-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 05:18:37PM +0800, Fan Du wrote:
> I'm not quite sure I get this "wildcard source address" right,
> IMHO if a host needs to protect every traffic for a given remote host=
,
> then the source address is wildcard address, i.e. all ZEROs.
> (Please correct me if I'm bloodly wrong=E3=80=82=E3=80=82=E3=80=82)

The above does not belong to a commit message, really.
If you are not sure and you want comments on your patch,
mark your patch as RFC. You should be sure that your patch
is correct when you submit, at least in the moment you
send it. I know that this can change a second after,
but in that moment you should be sure.

>=20
> Here is the argument if above statement stands true:
> __xfrm4/6_state_addr_check is a four steps check, all we need to do
> is checking whether the destination address match. Passing saddr from
> flow is worst option, as the checking needs to reach the fourth step.
>=20
> So, simply this process by only checking destination address only whe=
n
> using wildcard source address for looking up SAs.
>=20
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---

If you have further comments on your patch that should not be
included in the commit message, you can add them here.

>  include/net/xfrm.h    |   31 +++++++++++++++++++++++++++++++
>  net/xfrm/xfrm_state.c |    2 +-
>  2 files changed, 32 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index e253bf0..fdb9343 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -1282,6 +1282,37 @@ xfrm_state_addr_check(const struct xfrm_state =
*x,
>  }
> =20
>  static __inline__ int
> +__xfrm4_state_daddr_check(const struct xfrm_state *x,
> +                                const xfrm_address_t *daddr)
> +{
> +        return ((daddr->a4 =3D=3D x->id.daddr.a4) ? 1 : 0);
> +}
> +
> +static __inline__ int
> +__xfrm6_state_daddr_check(const struct xfrm_state *x,
> +                         const xfrm_address_t *daddr)
> +{
> +        if (ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_ad=
dr *)&x->id.daddr))
> +                return 1;
> +        else=20
> +                return 0;
> +}
> +
> +static __inline__ int
> +xfrm_state_daddr_check(const struct xfrm_state *x,
> +                      const xfrm_address_t *daddr,
> +                      unsigned short family)
> +{
> +        switch (family) {
> +        case AF_INET:
> +                return __xfrm4_state_daddr_check(x, daddr);
> +        case AF_INET6:
> +                return __xfrm6_state_daddr_check(x, daddr);
> +        }   =20
> +        return 0;
> +}

You used whitespaces where you should use tabs in the whole patch.
Please do the formating right to avoid cleanup patches.
