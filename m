From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v2 net-next 4/7] udp: prepare for non BH masking at
 backlog processing
Date: Fri, 29 Apr 2016 09:23:03 -0400
Message-ID: <CACSApvY8PZXsYXEFsqjGFihn608YE9s6VBOkSU0Mn9Z=gho9ew@mail.gmail.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com> <1461899449-8096-5-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35693 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbcD2NXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 09:23:44 -0400
Received: by mail-oi0-f50.google.com with SMTP id x19so117852764oix.2
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 06:23:43 -0700 (PDT)
In-Reply-To: <1461899449-8096-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 11:10 PM, Eric Dumazet <edumazet@google.com> wrote:
> UDP uses the generic socket backlog code, and this will soon
> be changed to not disable BH when protocol is called back.
>
> We need to use appropriate SNMP accessors.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  net/ipv4/udp.c | 4 ++--
>  net/ipv6/udp.c | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 093284c5c03b..f67f52ba4809 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1514,9 +1514,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>
>                 /* Note that an ENOMEM error is charged twice */
>                 if (rc == -ENOMEM)
> -                       __UDP_INC_STATS(sock_net(sk), UDP_MIB_RCVBUFERRORS,
> +                       UDP_INC_STATS(sock_net(sk), UDP_MIB_RCVBUFERRORS,
>                                         is_udplite);
> -               __UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
> +               UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
>                 kfree_skb(skb);
>                 trace_udp_fail_queue_rcv_skb(rc, sk);
>                 return -1;
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 1ba5a74ac18f..f911c63f79e6 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -570,9 +570,9 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>
>                 /* Note that an ENOMEM error is charged twice */
>                 if (rc == -ENOMEM)
> -                       __UDP6_INC_STATS(sock_net(sk),
> +                       UDP6_INC_STATS(sock_net(sk),
>                                          UDP_MIB_RCVBUFERRORS, is_udplite);
> -               __UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
> +               UDP6_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
>                 kfree_skb(skb);
>                 return -1;
>         }
> --
> 2.8.0.rc3.226.g39d4020
>
