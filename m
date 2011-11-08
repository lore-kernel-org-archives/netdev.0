From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TCLASS values
 via netlink
Date: Mon, 7 Nov 2011 16:25:00 -0800
Message-ID: <CANP3RGdj-vGz8Bx42T-m__2pi2_WsB4K=gamh-zxfaERmRARjw@mail.gmail.com>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Murali Raja <muralira@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:45257 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab1KHAZC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:25:02 -0500
Received: by ggnb2 with SMTP id b2so5843029ggn.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 16:25:01 -0800 (PST)
In-Reply-To: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46YI, This obviously requires a follow up patch which will add TOS and
TCLASS info to appropriate dual-stack sockets (for example listening
tcp v6 non-ipv6only).

On Mon, Nov 7, 2011 at 4:23 PM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>
> commit 3ceca749668a52bd795585e0f71c6f0b04814f7b added a TOS attribute=
=2E
>
> Unfortunately TOS and TCLASS are both present in a dual-stack v6 sock=
et,
> furthermore they can have different values. =C2=A0As such one cannot =
in a
> sane way expose both through a single attribute.
>
> Signed-off-by: Maciej =C5=BBenczyowski <maze@google.com>
> CC: Murali Raja <muralira@google.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David S. Miller <davem@davemloft.net>
> ---
> =C2=A0include/linux/inet_diag.h | =C2=A0 =C2=A03 ++-
> =C2=A0net/ipv4/inet_diag.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++--
> =C2=A02 files changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
> index 80b480c..abf5028 100644
> --- a/include/linux/inet_diag.h
> +++ b/include/linux/inet_diag.h
> @@ -98,9 +98,10 @@ enum {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INET_DIAG_VEGASINFO,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INET_DIAG_CONG,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INET_DIAG_TOS,
> + =C2=A0 =C2=A0 =C2=A0 INET_DIAG_TCLASS,
> =C2=A0};
>
> -#define INET_DIAG_MAX INET_DIAG_TOS
> +#define INET_DIAG_MAX INET_DIAG_TCLASS
>
>
> =C2=A0/* INET_DIAG_MEM */
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index f5e2bda..68e8ac5 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -133,8 +133,8 @@ static int inet_csk_diag_fill(struct sock *sk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &np->rcv_saddr);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ipv6_addr_copy=
((struct in6_addr *)r->id.idiag_dst,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &np->daddr);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ext & (1 << (I=
NET_DIAG_TOS - 1)))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 RTA_PUT_U8(skb, INET_DIAG_TOS, np->tclass);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ext & (1 << (I=
NET_DIAG_TCLASS - 1)))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0#endif
>
> --
> 1.7.3.1
>
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
