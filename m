From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 01/11] gso: Remove arbitrary checks for
 unsupported GSO
Date: Fri, 6 May 2016 19:44:45 -0700
Message-ID: <CAKgT0Uf82d4o8cHc+E9wfsTN=K-wNjiuAAU-16zx96AA9cxL+A@mail.gmail.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
	<1462572726-566137-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36091 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758951AbcEGCoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 22:44:46 -0400
Received: by mail-ig0-f177.google.com with SMTP id u10so62111627igr.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 19:44:45 -0700 (PDT)
In-Reply-To: <1462572726-566137-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 3:11 PM, Tom Herbert <tom@herbertland.com> wrote:
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index bbcf604..6de1e13 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -26,15 +26,6 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>         netdev_features_t mpls_features;
>         __be16 mpls_protocol;
>
> -       if (unlikely(skb_shinfo(skb)->gso_type &
> -                               ~(SKB_GSO_TCPV4 |
> -                                 SKB_GSO_TCPV6 |
> -                                 SKB_GSO_UDP |
> -                                 SKB_GSO_DODGY |
> -                                 SKB_GSO_TCP_FIXEDID |
> -                                 SKB_GSO_TCP_ECN)))
> -               goto out;
> -
>         /* Setup inner SKB. */
>         mpls_protocol = skb->protocol;
>         skb->protocol = skb->inner_protocol;

Actually I just noticed a build warning for this patch.  I guess the
label out isn't used anywhere else so you should probably drop it for
the mpls_gso_segment function.

- Alex
