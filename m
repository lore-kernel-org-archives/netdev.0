From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/1] GSO: Reload iph after pskb_may_pull
Date: Mon, 28 Nov 2016 08:34:59 -0800
Message-ID: <CAKgT0UdeSd91LUYWsHnnuKgM9bTydkzQ7r3B3n-nsVnT0gmzvg@mail.gmail.com>
References: <20161128153658.GB4778@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linux Networking Development Mailing List
        <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33395 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933181AbcK1QfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 11:35:01 -0500
Received: by mail-io0-f194.google.com with SMTP id j92so23799961ioi.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 08:35:00 -0800 (PST)
In-Reply-To: <20161128153658.GB4778@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 7:36 AM, Arnaldo Carvalho de Melo
<acme@kernel.org> wrote:
> As it may get stale and lead to use after free.
>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Alexander Duyck <aduyck@mirantis.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Fixes: cbc53e08a793 ("GSO: Add GSO type for fixed IPv4 ID")
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  net/ipv4/af_inet.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 5ddf5cda07f4..215143246e4b 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1233,7 +1233,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                 fixedid = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TCP_FIXEDID);
>
>                 /* fixed ID is invalid if DF bit is not set */
> -               if (fixedid && !(iph->frag_off & htons(IP_DF)))
> +               if (fixedid && !(ip_hdr(skb)->frag_off & htons(IP_DF)))
>                         goto out;
>         }
>
> --
> 2.9.3
>

Looks good to me.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
