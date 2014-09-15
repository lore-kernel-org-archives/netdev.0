From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 1/7] net: Export inet_offloads and inet6_offloads
Date: Mon, 15 Sep 2014 16:33:38 +0300
Message-ID: <CAJ3xEMgNqZ=qHmALiN_bFC5b3n8Ev-27Z7-KFG5Au6+x2A7=5g@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<1410750483-3236-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>, Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:36773 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbaIONdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 09:33:41 -0400
Received: by mail-ob0-f176.google.com with SMTP id wo20so447305obc.7
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 06:33:41 -0700 (PDT)
In-Reply-To: <1410750483-3236-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
> Want to be able to call this in foo-over-udp offloads, etc.

In the L2 gro case, we did dedicated helpers
gro_find_receive/complete_by_type, not sure what was
the exact rational there but worth checking, jerry?


>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/ipv4/protocol.c | 1 +
>  net/ipv6/protocol.c | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
> index 46d6a1c..4b7c0ec 100644
> --- a/net/ipv4/protocol.c
> +++ b/net/ipv4/protocol.c
> @@ -30,6 +30,7 @@
>
>  const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
>  const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
> +EXPORT_SYMBOL(inet_offloads);
>
>  int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
>  {
> diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
> index e048cf1..e3770ab 100644
> --- a/net/ipv6/protocol.c
> +++ b/net/ipv6/protocol.c
> @@ -51,6 +51,7 @@ EXPORT_SYMBOL(inet6_del_protocol);
>  #endif
>
>  const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS] __read_mostly;
> +EXPORT_SYMBOL(inet6_offloads);
>
>  int inet6_add_offload(const struct net_offload *prot, unsigned char protocol)
>  {
> --
> 2.1.0.rc2.206.gedb03e5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
