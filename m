From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: 2.6.39-rc: WARNING: at __ip_select_ident+0xd3/0xf0()
Date: Wed, 23 Mar 2011 14:22:12 +0300
Message-ID: <AANLkTikP5eBNQp2jwMKeFG-ZxcQGGkKdCfcds9D6t0dd@mail.gmail.com>
References: <AANLkTinacRCOx+z02n1OwBjGfVL5itzZs7Jqv_4PRXZK@mail.gmail.com>
	<1300873779.3063.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64481 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487Ab1CWLWN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 07:22:13 -0400
In-Reply-To: <1300873779.3063.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Thanks Alexander for this bug report.
>
> Here is a patch to fix this issue (and other crash you mentioned in n=
ext
> mail)
>
Hi Eric,
Thank you for the fix, have not it checked however.

I did not know that the second problem
(https://lkml.org/lkml/2011/3/23/38) had the same reason.
I did not notice inetpeer_free_rcu() in its calltrace.

Thanks for that.
>
> [PATCH] ipv4: fix ip_rt_update_pmtu()
>
> commit 2c8cec5c10bc (Cache learned PMTU information in inetpeer) adde=
d
> an extra inet_putpeer() call in ip_rt_update_pmtu().
>
> This results in various problems, since we can free one inetpeer, whi=
le
> it is still in use.
>
> Ref: http://www.spinics.net/lists/netdev/msg159121.html
>
> Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =C2=A0net/ipv4/route.c | =C2=A0 =C2=A02 --
> =C2=A01 file changed, 2 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 870b518..34921b0 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1593,8 +1593,6 @@ static void ip_rt_update_pmtu(struct dst_entry =
*dst, u32 mtu)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0rt->rt_peer_genid =3D rt_peer_genid();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0check_peer_pmt=
u(dst, peer);
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 inet_putpeer(peer)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0}
>
>
>
>
