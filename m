From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [Patch net-next v2] ping: always initialize ->sin6_scope_id and ->sin6_flowinfo
Date: Mon, 3 Jun 2013 18:25:39 +0900
Message-ID: <CAKD1Yr1f=LtJGnzOEoy2Co2A_2LzqjSdU6dJZWCy3+WeXWJe3g@mail.gmail.com>
References: <1370249032-14903-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:43084 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab3FCJ0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 05:26:00 -0400
Received: by mail-qa0-f45.google.com with SMTP id o13so1692363qaj.11
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 02:25:59 -0700 (PDT)
In-Reply-To: <1370249032-14903-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 3, 2013 at 5:43 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> If we don't need scope id, we should initialize it to zero.
> Same for ->sin6_flowinfo.
>
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/ipv4/ping.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 71f6ad0..0f419a2 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -892,12 +892,12 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>                 sin6->sin6_port = 0;
>                 sin6->sin6_addr = ip6->saddr;
>
> +               sin6->sin6_flowinfo = 0;
>                 if (np->sndflow)
>                         sin6->sin6_flowinfo = ip6_flowinfo(ip6);
>
> -               if (__ipv6_addr_needs_scope_id(
> -                   ipv6_addr_type(&sin6->sin6_addr)))
> -                       sin6->sin6_scope_id = IP6CB(skb)->iif;
> +               sin6->sin6_scope_id = ipv6_iface_scope_id(&sin6->sin6_addr,
> +                                                         IP6CB(skb)->iif);
>
>                 if (inet6_sk(sk)->rxopt.all)
>                         pingv6_ops.ip6_datagram_recv_ctl(sk, msg, skb);

Acked-by: Lorenzo Colitti <lorenzo@google.com>
