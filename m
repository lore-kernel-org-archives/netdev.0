From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/9] net: Remove martian_source_keep_err goto label
Date: Wed, 23 Sep 2015 09:19:15 -0700
Message-ID: <CALx6S35EmX--C5c=4X1YZR7_botr3c1+CYMigonniDO8jCZkoA@mail.gmail.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
	<1443021322-48621-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35811 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbbIWQTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:19:16 -0400
Received: by ioiz6 with SMTP id z6so48431512ioi.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:19:15 -0700 (PDT)
In-Reply-To: <1443021322-48621-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 8:15 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> err is initialized to -EINVAL when it is declared. It is not reset until
> fib_lookup which is well after the 3 users of the martian_source jump. So
> resetting err to -EINVAL at martian_source label is not needed.
>
> Removing that line obviates the need for the martian_source_keep_err label
> so delete it.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv4/route.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 80f7c5b7b832..ef36dfed24da 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1760,7 +1760,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>                 err = fib_validate_source(skb, saddr, daddr, tos,
>                                           0, dev, in_dev, &itag);
>                 if (err < 0)
> -                       goto martian_source_keep_err;
> +                       goto martian_source;
>                 goto local_input;
>         }
>
> @@ -1782,7 +1782,7 @@ out:      return err;
>                 err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
>                                           in_dev, &itag);
>                 if (err < 0)
> -                       goto martian_source_keep_err;
> +                       goto martian_source;
>         }
>         flags |= RTCF_BROADCAST;
>         res.type = RTN_BROADCAST;
> @@ -1858,8 +1858,6 @@ out:      return err;
>         goto out;
>
>  martian_source:
> -       err = -EINVAL;
Just remove t=above line, no need to rename label.

> -martian_source_keep_err:
>         ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
>         goto out;
>  }
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
