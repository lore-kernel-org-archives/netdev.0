From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: fib6_rules should return exact
 return value
Date: Thu, 01 Aug 2013 00:26:46 -0700 (PDT)
Message-ID: <20130801.002646.2055621855734330896.davem@davemloft.net>
References: <20130801065447.GE3688@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefan.tomanek@wertarbyte.de,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab3HAH0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 03:26:47 -0400
In-Reply-To: <20130801065447.GE3688@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 1 Aug 2013 08:54:47 +0200

> With the addition of the suppress operation
> (7764a45a8f1fe74d4f7d301eaca2e558e7e2831a ("fib_rules: add .suppress
> operation") we rely on accurate error reporting of the fib_rules.actions.
> 
> fib6_rule_action always returned -EAGAIN in case we could not find a
> matching route and 0 if a rule was matched. This also included a match
> for blackhole or prohibited rule actions which could get suppressed by
> the new logic.
> 
> So adapt fib6_rule_action to always return the correct error code as
> its counterpart fib4_rule_action does. This also fixes a possiblity of
> nullptr-deref where we don't find a table, thus rt == NULL. Because
> the condition rt != ip6_null_entry still holdes it seems we could later
> get a nullptr bug on dereference rt->dst.
> 
> v2:
> a) Fixed a brain fart in the commit msg (the rule => a table, etc). No
>    changes to the patch.
> 
> Cc: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied, thanks.
