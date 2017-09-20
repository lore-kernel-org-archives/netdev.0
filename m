From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] ipv6_skip_exthdr: use ipv6_authlen for AH hdrlen
Date: Tue, 19 Sep 2017 17:38:21 -0700
Message-ID: <CALx6S34JiwxvbvwnJsu-R+7XuGBe6HbnzT46TEPYaTYQ9_Z9HA@mail.gmail.com>
References: <20170919125950.11537-1-qasdfgtyuiop@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: trivial@kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Xiang Gao <qasdfgtyuiop@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:37535 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdITAiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 20:38:22 -0400
Received: by mail-qk0-f193.google.com with SMTP id r66so784472qke.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 17:38:22 -0700 (PDT)
In-Reply-To: <20170919125950.11537-1-qasdfgtyuiop@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 5:59 AM, Xiang Gao <qasdfgtyuiop@gmail.com> wrote:
> In ipv6_skip_exthdr, the lengh of AH header is computed manually
> as (hp->hdrlen+2)<<2. However, in include/linux/ipv6.h, a macro
> named ipv6_authlen is already defined for exactly the same job. This
> commit replaces the manual computation code with the macro.

This isn't directly related to this patch, but I notice that flow
dissector doesn't used the ipv6_optlen macro and doesn't have
NEXTHDR_AUTH or NEXTHDR_NONE in the ip_proto switch statement. Would
be a nice fix. The NEXTHDR_NONE is probably just a break, but would be
nice to have it there for completeness.

Tom

> ---
>  net/ipv6/exthdrs_core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
> index 305e2ed730bf..115d60919f72 100644
> --- a/net/ipv6/exthdrs_core.c
> +++ b/net/ipv6/exthdrs_core.c
> @@ -99,7 +99,7 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
>                                 break;
>                         hdrlen = 8;
>                 } else if (nexthdr == NEXTHDR_AUTH)
> -                       hdrlen = (hp->hdrlen+2)<<2;
> +                       hdrlen = ipv6_authlen(hp);
>                 else
>                         hdrlen = ipv6_optlen(hp);
>
> --
> 2.14.1
>
