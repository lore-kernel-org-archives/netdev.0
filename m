From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next] ipv6: move IPV6_TCLASS_SHIFT into ipv6.h
Date: Thu, 9 Jan 2014 18:18:48 +0800
Message-ID: <CAJFZqHwLap==WKDAwtPeL+oUOtvJ+j7S8VJBUDXV-Q7_21Jx2Q@mail.gmail.com>
References: <1389173868-14387-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:53890 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbaAIKSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 05:18:49 -0500
Received: by mail-ve0-f173.google.com with SMTP id oz11so2232278veb.32
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 02:18:49 -0800 (PST)
In-Reply-To: <1389173868-14387-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 8, 2014 at 5:37 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> Two places defined IPV6_TCLASS_SHIFT, so we should move it into ipv6.h,
> and use this macro as possible.
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  include/net/ipv6.h       |    1 +
>  net/ipv6/fib6_rules.c    |    4 +++-
>  net/ipv6/ip6_gre.c       |    2 --
>  net/ipv6/ip6_tunnel.c    |    2 --
>  net/ipv6/ipv6_sockglue.c |    4 +++-
>  5 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 12079c6..d819f7a 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -239,6 +239,7 @@ struct ip6_flowlabel {
>  #define IPV6_FLOWINFO_MASK     cpu_to_be32(0x0FFFFFFF)
>  #define IPV6_FLOWLABEL_MASK    cpu_to_be32(0x000FFFFF)
>  #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
> +#define IPV6_TCLASS_SHIFT      20
>
>  struct ipv6_fl_socklist {
>         struct ipv6_fl_socklist __rcu   *next;
> diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
> index 3fd0a57..d50c5ca 100644
> --- a/net/ipv6/fib6_rules.c
> +++ b/net/ipv6/fib6_rules.c
> @@ -150,6 +150,8 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
>  {
>         struct fib6_rule *r = (struct fib6_rule *) rule;
>         struct flowi6 *fl6 = &fl->u.ip6;
> +       u8 tclass = (ntohl(fl6->flowlabel) & IPV6_TCLASS_MASK) >>
> +                   IPV6_TCLASS_SHIFT;

Please drop this patch, it has bug.

The correct should be:

u8 tclass =ntohl(fl6->flowlabe & IPV6_TCLASS_MASK) >> IPV6_TCLASS_SHIFT

Thanks

-Roy
