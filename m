From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 7/7] gre: TX path for GRE/UDP foo-over-udp encapsulation
Date: Mon, 15 Sep 2014 16:18:32 +0300
Message-ID: <CAJ3xEMhtjGd7VZcHRjDb0eT7wxUae-ixp=+HY71wpzDGGrUvVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:56174 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbaIONSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 09:18:37 -0400
Received: by mail-ob0-f180.google.com with SMTP id wp4so2388484obc.25
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 06:18:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 6:08 AM, Tom Herbert <therbert@google.com> wrote:

Empty change log here and also on patches 5 and 6, can you please add
it in v3 and also reply here with short write up? I assume the text
for patches 5/6/7 would be similar so for V2 enough if you just reply
here.


> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/uapi/linux/if_tunnel.h |  4 ++
>  net/ipv4/ip_gre.c              | 98 +++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 95 insertions(+), 7 deletions(-)
>
> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
> index 9fedca7..7c832af 100644
> --- a/include/uapi/linux/if_tunnel.h
> +++ b/include/uapi/linux/if_tunnel.h
> @@ -106,6 +106,10 @@ enum {
>         IFLA_GRE_ENCAP_LIMIT,
>         IFLA_GRE_FLOWINFO,
>         IFLA_GRE_FLAGS,
> +       IFLA_GRE_ENCAP_TYPE,
> +       IFLA_GRE_ENCAP_FLAGS,
> +       IFLA_GRE_ENCAP_SPORT,
> +       IFLA_GRE_ENCAP_DPORT,
>         __IFLA_GRE_MAX,
>  };
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 9b84254..5681344 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -239,7 +239,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
>         tpi.seq = htonl(tunnel->o_seqno);
>
>         /* Push GRE header. */
> -       gre_build_header(skb, &tpi, tunnel->hlen);
> +       gre_build_header(skb, &tpi, tunnel->tun_hlen);
>
>         ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
>  }

If I got it right, this hunk is the only part of the patch that deals
with the TX path and the test is setup, right? would be good to
reflect that in the patch title, maybe something like "Setup and TX
path for [...]" ditto for patches 5/6

Or
