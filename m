From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Added NLM_F_EXCL support to fib_nl_newrule
Date: Mon, 23 May 2016 14:29:40 -0700 (PDT)
Message-ID: <20160523.142940.559311739401468603.davem@davemloft.net>
References: <573F341F.7020302@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mateusz.bajorski@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbcEWV3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 17:29:41 -0400
In-Reply-To: <573F341F.7020302@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mateusz Bajorski <mateusz.bajorski@nokia.com>
Date: Fri, 20 May 2016 17:58:23 +0200


Please format your Subject line properly, it should be of the form:

	[PATCH] $SUBSYSTEM: Description.

In this case "fib_fules: " would be an appropriate subsystem
specification.

> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index 840aceb..b9816a3 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -291,6 +291,47 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
>  	if (err < 0)
>  		goto errout;
>  
> +	if (nlh->nlmsg_flags & NLM_F_EXCL) {
> +		list_for_each_entry(rule, &ops->rules_list, list) {
> +			if (frh->action && (frh->action != rule->action))
> +				continue;
> +
> +			if (frh_get_table(frh, tb) &&
> +				frh_get_table(frh, tb) != rule->table)
> +				continue;

First of all, this is not indented properly.

When a conditional, or function call, spans multiple lines, the second
and subsequent lines must be indented precisely to the first column
after the openning parenthesis of the first line.  You must use the
appropriate number of TAB and SPACE characters necessary to do so.

Second of all, this is so messy having to check the 'tb' pointers over
and over again each iteration of the loop.

It's therefore much better to put this check later in the function long
after we've built the whole new rule, right before we do the priority
ordering loop.
