From: Kishan Sandeep <sandeepkishan108@gmail.com>
Subject: Re: [PATCH] netfilter: fix buffer null termination
Date: Mon, 13 Jun 2016 21:07:19 +0530
Message-ID: <CAJ3s=NAf5x3W9spRjxKKnX0Qxoc+nmr3rRkNy5dKYbyXG6mP4g@mail.gmail.com>
References: <1465620484-5543-1-git-send-email-sandeepkishan108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: pablo@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33565 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424071AbcFMPhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 11:37:20 -0400
Received: by mail-io0-f194.google.com with SMTP id 5so17172600ioy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 08:37:20 -0700 (PDT)
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
