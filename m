From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next v3 1/4] ipv4: no CHECKSUM_PARTIAL on MSG_MORE
 corked sockets
Date: Tue, 27 Oct 2015 15:22:55 -0700
Message-ID: <CALx6S35udd410V5bEzH2OxE=Qug0fydo10-X6E__gwzeGYCtzg@mail.gmail.com>
References: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
	<1445982042-3207-2-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33628 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311AbbJ0WWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 18:22:55 -0400
Received: by igbkq10 with SMTP id kq10so105531963igb.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 15:22:55 -0700 (PDT)
In-Reply-To: <1445982042-3207-2-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 2:40 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> We cannot reliable calculate packet size on MSG_MORE corked sockets
> and thus cannot decide if they are going to be fragmented later on,
> so better not use CHECKSUM_PARTIAL in the first place.
>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Benjamin Coddington <bcodding@redhat.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv4/ip_output.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 50e2973..0b02417 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -911,6 +911,7 @@ static int __ip_append_data(struct sock *sk,
>         if (transhdrlen &&
>             length + fragheaderlen <= mtu &&
>             rt->dst.dev->features & NETIF_F_V4_CSUM &&
> +           !(flags & MSG_MORE) &&

I still don't understand this. It seems like the effect is to disable
checksum offload for all UDP messages sent with MSG_MORE flag set.

>             !exthdrlen)
>                 csummode = CHECKSUM_PARTIAL;
>
> --
> 2.5.0
>
