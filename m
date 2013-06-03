From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [Patch net-next 2/2] ping: use ipv6_iface_scope_id() to get scope id
Date: Mon, 3 Jun 2013 16:59:58 +0900
Message-ID: <CAKD1Yr1gSjGq-G-G_YLgpUNTy5P8H-OD+rnqLCyW18mVB_bGDg@mail.gmail.com>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com> <1370238959-32008-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:57342 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3FCIAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 04:00:19 -0400
Received: by mail-qe0-f43.google.com with SMTP id k5so2168091qej.30
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 01:00:18 -0700 (PDT)
In-Reply-To: <1370238959-32008-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 3, 2013 at 2:55 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> If we don't need scope id, we should initialize it to zero.
>
> Cc: Lorenzo Colitti <lorenzo@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/ipv4/ping.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index 8c92781..b1993b3 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -905,9 +905,8 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
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
> --
> 1.7.7.6
>

Good catch, thanks. While you're at it - if np->sndflow is false,
sin6_flowinfo is not being initialized either. Care to fix that too?
The other functions do this like this:

sin->sin6_flowinfo = 0;
if (np->sndflow)
        sin6->sin6_flowinfo = ip6_flowinfo(ip6);
