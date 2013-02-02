From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] net: Fix inner_network_header assignment in skb-copy.
Date: Fri, 1 Feb 2013 19:57:50 -0500
Message-ID: <CAP=VYLqYDLeLssrwizRGChygEPwLRSwXBh+YkSr4F7MW1XiGtw@mail.gmail.com>
References: <1359764763-1618-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:60183 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757326Ab3BBA6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 19:58:22 -0500
Received: by mail-we0-f176.google.com with SMTP id s43so3347277wey.7
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 16:58:20 -0800 (PST)
In-Reply-To: <1359764763-1618-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 1, 2013 at 7:26 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Hi Pravin,

As a general rule of thumb, a commit log should cover these three
basic things:

1) What are the end user visible symptoms of this issue (i.e. does it panic,
does it hang, do applications segfault, etc etc).

2) Why does this happen?  i.e. explain where the logic error is in the
existing code base and so forth.

3) How do we best fix this?   i.e. explain what our options are to fix
the issue, and why your choice of fixes is technically the best choice.

With no long log whatsoever, your change does not cover any of
the #1, #2 or #3.  And without that, it also makes review by the
maintainers more difficult, and reduces the chance that your
patch will be integrated into mainline.  Can you perhaps resend
with a more detailed commit log, given the above information?

Thanks,
Paul.
--


> ---
>  net/core/skbuff.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index bddc1dd..55f7ef6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -686,7 +686,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
>         new->network_header     = old->network_header;
>         new->mac_header         = old->mac_header;
>         new->inner_transport_header = old->inner_transport_header;
> -       new->inner_network_header = old->inner_transport_header;
> +       new->inner_network_header = old->inner_network_header;
>         skb_dst_copy(new, old);
>         new->rxhash             = old->rxhash;
>         new->ooo_okay           = old->ooo_okay;
> --
> 1.7.10
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
