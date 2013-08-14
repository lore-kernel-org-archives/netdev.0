From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
Date: Wed, 14 Aug 2013 13:34:36 +0200
Message-ID: <20130814113436.GI26773@secunet.com>
References: <1375772225-19265-1-git-send-email-fan.du@windriver.com>
 <20130806092220.GH25511@secunet.com>
 <52087537.6060200@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60373 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759817Ab3HNLej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 07:34:39 -0400
Content-Disposition: inline
In-Reply-To: <52087537.6060200@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 01:40:07PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B408=E6=9C=8806=E6=97=A5 17:22, Steffen Klassert wrote:
> >On Tue, Aug 06, 2013 at 02:57:05PM +0800, Fan Du wrote:
> >>xfrm_state timer should be independent of system clock change,
> >>so switch to monotonic clock base.
> >>
> >
> >I think a monotonic timer will reintroduce a bug on suspend/resume
> >that was fixed by commit 9e0d57fd6
> >(xfrm: SAD entries do not expire correctly after suspend-resume)
> >
> >Please make sure that this does not happen.
>=20
> What about using CLOCK_BOOTTIME? it's monotonic, but includes suspend=
 time as well.
>=20
>=20
> From 1dae5a22c203224ee46e2a2f95b569a04b74117b Mon Sep 17 00:00:00 200=
1
> From: Fan Du <fan.du@windriver.com>
> Date: Mon, 12 Aug 2013 13:33:45 +0800
> Subject: [PATCHv2 net-next] xfrm: Make xfrm_state timer monotonic
>=20
> xfrm_state timer should be independent of system clock change,
> so switch to CLOCK_BOOTTIME base which is not only monotonic but
> also counting suspend time.
>=20
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>  net/xfrm/xfrm_state.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 78f66fa..1df4436 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -499,7 +499,7 @@ struct xfrm_state *xfrm_state_alloc(struct net *n=
et)
>  		INIT_HLIST_NODE(&x->bydst);
>  		INIT_HLIST_NODE(&x->bysrc);
>  		INIT_HLIST_NODE(&x->byspi);
> -		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_REALTIM=
E, HRTIMER_MODE_ABS);
> +		tasklet_hrtimer_init(&x->mtimer, xfrm_timer_handler, CLOCK_BOOTTIM=
E, HRTIMER_MODE_ABS);
>  		setup_timer(&x->rtimer, xfrm_replay_timer_handler,
>  				(unsigned long)x);
>  		x->curlft.add_time =3D get_seconds();

This does not apply to my tree, looks like your patch is whitespace dam=
aged.
