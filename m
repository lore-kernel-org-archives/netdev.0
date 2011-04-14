From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Wed, 13 Apr 2011 19:54:24 -0700
Message-ID: <20110413195424.1d2393c6@s6510>
References: <4DA522B2.90200@scotdoyle.com>
	<4DA5BCF7.9020606@scotdoyle.com>
	<1302708487.3725.0.camel@edumazet-laptop>
	<20110413.144812.116375845.davem@davemloft.net>
	<1302748276.3549.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	shimoda.hiroaki@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758617Ab1DNCy1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 22:54:27 -0400
In-Reply-To: <1302748276.3549.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2011 04:31:16 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 13 avril 2011 =C3=A0 14:48 -0700, David Miller a =C3=A9cr=
it :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 13 Apr 2011 17:28:07 +0200
> >=20
> > > Dont worry, Stephen or me will send it asap.
> >=20
> > I'm looking forward to it :)
>=20
> I was considering another way to handle this problem,
> patching ip_options_compile() to take care of null skb_dst() in slow
> path instead ?
>=20
> What would be the best thing ?
>=20
> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index 28a736f..c10ad63 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -329,7 +329,7 @@ int ip_options_compile(struct net *net,
>  					pp_ptr =3D optptr + 2;
>  					goto error;
>  				}
> -				if (skb) {
> +				if (rt) {
>  					memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
>  					opt->is_changed =3D 1;
>  				}
> @@ -371,7 +371,7 @@ int ip_options_compile(struct net *net,
>  						goto error;
>  					}
>  					opt->ts =3D optptr - iph;
> -					if (skb) {
> +					if (rt)  {
>  						memcpy(&optptr[optptr[2]-1], &rt->rt_spec_dst, 4);
>  						timeptr =3D (__be32*)&optptr[optptr[2]+3];
>  					}
>=20

I like this because it lets the bridge be transparent.
The existing options code adds entry in record route, and which
is not desirable.
