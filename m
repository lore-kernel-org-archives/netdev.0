From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2] ip_tunnel: Add missing validation of encap type to ip_tunnel_encap_setup()
Date: Tue, 16 Dec 2014 12:23:24 -0800
Message-ID: <CA+mtBx_364iHXxLkA=Ytb=34_2zEy9-3hqfOdt96Ckhm8NwFiQ@mail.gmail.com>
References: <cover.1418759998.git.tgraf@suug.ch>
	<dd70de766b1111fdcb4794f6d671e4eca5053730.1418759998.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:32983 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaLPUXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:23:30 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so7539101igb.5
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 12:23:29 -0800 (PST)
In-Reply-To: <dd70de766b1111fdcb4794f6d671e4eca5053730.1418759998.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 16, 2014 at 12:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> The encap->type comes straight from Netlink. Validate it against
> max supported encap types just like ip_encap_hlen() already does.
>
> Fixes: a8c5f9 ("ip_tunnel: Ops registration for secondary encap (fou, gue)")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/ipv4/ip_tunnel.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 2f498f8..d3e4479 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -573,6 +573,9 @@ int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
>         if (t->encap.type == TUNNEL_ENCAP_NONE)
>                 return 0;
>
> +       if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
> +               return -EINVAL;
> +

I don't think this is technically needed, we should have already
verified the type when setting up the tunnel (ip_encap_hlen).

>         rcu_read_lock();
>         ops = rcu_dereference(iptun_encaps[t->encap.type]);
>         if (likely(ops && ops->build_header))
> --
> 1.9.3
>
