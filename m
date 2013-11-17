From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] fix NULL pointer Oops in fib(6)_rule_suppress
Date: Sun, 17 Nov 2013 17:56:43 +0400
Message-ID: <5288CB1B.7050806@cogentembedded.com>
References: <20131117111409.GB23153@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Golle <daniel@makrotopia.org>
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:43992 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab3KQN4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 08:56:48 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so1578318lbv.24
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 05:56:47 -0800 (PST)
In-Reply-To: <20131117111409.GB23153@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-11-2013 15:14, Stefan Tomanek wrote:

> Reported-by: Daniel Golle <daniel.golle@gmail.com>
> Tested-by: Daniel Golle <daniel.golle@gmail.com>
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
> ---
>   net/ipv4/fib_rules.c  |    4 +++-
>   net/ipv6/fib6_rules.c |    5 ++++-
>   2 files changed, 7 insertions(+), 2 deletions(-)

> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index 523be38..4e1c1e5 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -104,7 +104,9 @@ errout:
>   static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
>   {
>   	struct fib_result *result = (struct fib_result *) arg->result;
> -	struct net_device *dev = result->fi->fib_dev;
> +	struct net_device *dev = NULL;

    Please leave empty line after declarations, like it was before your patch.

> +	if (result->fi)
> +		dev = result->fi->fib_dev;
>
>   	/* do not accept result if the route does
>   	 * not meet the required prefix length
> diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
> index e275916..43e45b5 100644
> --- a/net/ipv6/fib6_rules.c
> +++ b/net/ipv6/fib6_rules.c
> @@ -122,7 +122,10 @@ out:
>   static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
>   {
>   	struct rt6_info *rt = (struct rt6_info *) arg->result;
> -	struct net_device *dev = rt->rt6i_idev->dev;
> +	struct net_device *dev = NULL;

    Same here.

> +	if (rt->rt6i_idev)
> +		dev = rt->rt6i_idev->dev;
> +

WBR, Sergei
