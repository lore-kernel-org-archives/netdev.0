From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: strparser: fix strparser sk_user_data check
Date: Mon, 22 Aug 2016 12:35:38 -0700
Message-ID: <CALx6S35w4oe9ds-cWadKmT_n__3-NKFZ6hw=KFzKFNBx+Dj=2g@mail.gmail.com>
References: <20160822192704.GA34359@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33841 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756116AbcHVTfj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 15:35:39 -0400
Received: by mail-it0-f68.google.com with SMTP id e63so5670071ith.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 12:35:39 -0700 (PDT)
In-Reply-To: <20160822192704.GA34359@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 12:27 PM, Dave Watson <davejwatson@fb.com> wrote:
> sk_user_data mismatch between what kcm expects (psock) and what strparser expects (strparser).
>
> Queued rx_work, for example calling strp_check_rcv after socket buffer changes, will never complete.
>
> sk_user_data is unused in strparser, so just remove the check.
>
> Signed-off-by: Dave Watson <davejwatson@fb.com>
> ---
>  net/strparser/strparser.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
> index fd688c0..68334b5 100644
> --- a/net/strparser/strparser.c
> +++ b/net/strparser/strparser.c
> @@ -390,9 +390,6 @@ static void do_strp_rx_work(struct strparser *strp)
>          */
>         lock_sock(csk);
>
> -       if (unlikely(csk->sk_user_data != strp))
> -               goto out;
> -

Acked-by: Tom Herbert <tom@herbertland.com>

>         if (unlikely(strp->rx_stopped))
>                 goto out;
>
> --
> 2.8.0.rc2
>
