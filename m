From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] p54: add null pointer check before releasing socket buffer
Date: Mon, 10 Apr 2017 14:38:02 -0700
Message-ID: <CANn89iK+DciFiUwPjQv5SSj_wp+CjiPtG5GO8bBKkkyrqDrNxg@mail.gmail.com>
References: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
 <3716717.OUypxXNBrR@debian64> <20170410205414.GB12557@fqdn.specialj.com> <1896493.H38pOMoCHn@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Myungho Jung <mhjungk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1896493.H38pOMoCHn@debian64>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 2:22 PM, Christian Lamparter
<chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:

> Well, the patch could be as simple as this:
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7869ae3837ca..44f7d5a1c67c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2450,6 +2450,9 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
>  {
>         unsigned long flags;
>
> +       if (!skb)
> +               return;
> +
>         if (likely(atomic_read(&skb->users) == 1)) {
>                 smp_rmb();
>                 atomic_set(&skb->users, 0);
> ---
>
> The question is: would David or Eric support the change. Any comments,
> what's the prefered solution? Just patch __dev_kfree_skb_irq to make
> it consistent with *kfree*, or patch the driver? I'm fine either way,
> but I would prefere patching __dev_kfree_skb_irq.

This is fine, same check happens in consume_skb()
