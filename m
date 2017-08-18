From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net-next] ipv4: convert dst_metrics.refcnt from
 atomic_t to refcount_t
Date: Fri, 18 Aug 2017 10:15:08 -0700
Message-ID: <CAM_iQpWbxs6aa-axQrwN5pipaCDX3ws_08LaQON8p4WfrJ7SDg@mail.gmail.com>
References: <1502911469.4936.148.camel@edumazet-glaptop3.roam.corp.google.com> <1502925599.4936.153.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37819 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdHRRP3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:15:29 -0400
Received: by mail-pg0-f65.google.com with SMTP id 83so15947518pgb.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 10:15:29 -0700 (PDT)
In-Reply-To: <1502925599.4936.153.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: fix a missing change in net/ipv4/fib_semantics.c
>
>  include/net/dst.h        |    2 +-
>  net/core/dst.c           |    6 +++---
>  net/ipv4/fib_semantics.c |    4 ++--
>  net/ipv4/route.c         |    4 ++--
>  4 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/dst.h b/include/net/dst.h
> index f73611ec401754d4f52b5310a24da53566dafce6..dd38177c3a61f5c4e48be9d57d4d10d6b7d14672 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -107,7 +107,7 @@ struct dst_entry {
>
>  struct dst_metrics {
>         u32             metrics[RTAX_MAX];
> -       atomic_t        refcnt;
> +       refcount_t      refcnt;
>  };
>  extern const struct dst_metrics dst_default_metrics;


#include linux/refcount.h explicitly?
