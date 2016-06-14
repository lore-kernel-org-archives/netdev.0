From: Kishan Sandeep <sandeepkishan108@gmail.com>
Subject: Re: [PATCH] netfilter: fix buffer null termination
Date: Tue, 14 Jun 2016 19:39:27 +0530
Message-ID: <CAJ3s=NBCvYnRaWcFb==vZqP1_YE6w=uKqbtBvESkCo1sED2CHg@mail.gmail.com>
References: <1465620484-5543-1-git-send-email-sandeepkishan108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: pablo@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34622 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbcFNOJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 10:09:28 -0400
Received: by mail-it0-f66.google.com with SMTP id d71so11315944ith.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 07:09:28 -0700 (PDT)
In-Reply-To: <1465620484-5543-1-git-send-email-sandeepkishan108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ netdev

On Sat, Jun 11, 2016 at 10:18 AM, Kishan Sandeep
<sandeepkishan108@gmail.com> wrote:
> strncpy generally perferable fo non-terminated
> fixed-width strings. For NULL termination strlcpy
> is preferrable.
>
> Signed-off-by: Kishan Sandeep <sandeepkishan108@gmail.com>
> ---
>  net/netfilter/xt_repldata.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldata.h
> index 8fd3241..a460211 100644
> --- a/net/netfilter/xt_repldata.h
> +++ b/net/netfilter/xt_repldata.h
> @@ -28,7 +28,7 @@
>         if (tbl == NULL) \
>                 return NULL; \
>         term = (struct type##_error *)&(((char *)tbl)[term_offset]); \
> -       strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
> +       strlcpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
>         *term = (struct type##_error)typ2##_ERROR_INIT;  \
>         tbl->repl.valid_hooks = hook_mask; \
>         tbl->repl.num_entries = nhooks + 1; \
> --
> 1.7.9.5
>
