From: Tom Herbert <tom@herbertland.com>
Subject: Re: [Patch net] kcm: fix a null pointer dereference in kcm_sendmsg()
Date: Mon, 13 Feb 2017 11:18:10 -0800
Message-ID: <CALx6S37U6zYd1Pr6B3OfAXYBPXhGeLTrwFX6s1b7aR-BRnbLmg@mail.gmail.com>
References: <1487013196-2375-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        dvyukov@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35726 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752423AbdBMTSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 14:18:11 -0500
Received: by mail-qk0-f194.google.com with SMTP id u25so16233205qki.2
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 11:18:11 -0800 (PST)
In-Reply-To: <1487013196-2375-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 11:13 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> In commit 98e3862ca2b1 ("kcm: fix 0-length case for kcm_sendmsg()")
> I tried to avoid skb allocation for 0-length case, but missed
> a check for NULL pointer in the non EOR case.
>
> Fixes: 98e3862ca2b1 ("kcm: fix 0-length case for kcm_sendmsg()")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  net/kcm/kcmsock.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
> index 64f0e85..a646f34 100644
> --- a/net/kcm/kcmsock.c
> +++ b/net/kcm/kcmsock.c
> @@ -1044,8 +1044,10 @@ static int kcm_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
>         } else {
>                 /* Message not complete, save state */
>  partial_message:
> -               kcm->seq_skb = head;
> -               kcm_tx_msg(head)->last_skb = skb;
> +               if (head) {
> +                       kcm->seq_skb = head;
> +                       kcm_tx_msg(head)->last_skb = skb;
> +               }
>         }
>
>         KCM_STATS_ADD(kcm->stats.tx_bytes, copied);
> --
> 2.5.5
>
