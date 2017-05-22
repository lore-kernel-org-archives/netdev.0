From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] net/core: remove explicit do_softirq() from busy_poll_stop()
Date: Mon, 22 May 2017 14:26:44 -0700
Message-ID: <CANn89iJx0-z2KZWMRZdqmYUNAWcqQo4nBbRwK7pLz2-WAymqrQ@mail.gmail.com>
References: <20170522192641.hylqmhb7t2fykk5e@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f174.google.com ([209.85.213.174]:34184 "EHLO
        mail-yb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934001AbdEVV0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 17:26:46 -0400
Received: by mail-yb0-f174.google.com with SMTP id 132so33640236ybq.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 14:26:45 -0700 (PDT)
In-Reply-To: <20170522192641.hylqmhb7t2fykk5e@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 12:26 PM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> Since commit 217f69743681 ("net: busy-poll: allow preemption in
> sk_busy_loop()") there is an explicit do_softirq() invocation after
> local_bh_enable() has been invoked.
> I don't understand why we need this because local_bh_enable() will
> invoke do_softirq() once the softirq counter reached zero and we have
> softirq-related work pending.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  net/core/dev.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fca407b4a6ea..e84eb0ec5529 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5199,8 +5199,6 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
>         if (rc == BUSY_POLL_BUDGET)
>                 __napi_schedule(napi);
>         local_bh_enable();
> -       if (local_softirq_pending())
> -               do_softirq();
>  }

preemption is disabled.

Look at netif_rx_ni() for a similar construct.

What exact problem do you have with existing code, that is worth
adding this change ?

Thanks.
