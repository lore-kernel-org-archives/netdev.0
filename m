From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] fib_rules: add .suppress operation
Date: Wed, 31 Jul 2013 17:27:40 -0700 (PDT)
Message-ID: <20130731.172740.549970338016485006.davem@davemloft.net>
References: <20130727070758.GA23904@order.stressinduktion.org>
	<20130801001715.GA27283@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856Ab3HAA1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 20:27:41 -0400
In-Reply-To: <20130801001715.GA27283@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Thu, 1 Aug 2013 02:17:15 +0200

> This change adds a new operation to the fib_rules_ops struct; it allows the
> suppression of routing decisions if certain criteria are not met by its
> results.
> 
> The first implemented constraint is a minimum prefix length added to the
> structures of routing rules. If a rule is added with a minimum prefix length
>>0, only routes meeting this threshold will be considered. Any other (more
> general) routing table entries will be ignored.
> 
> When configuring a system with multiple network uplinks and default routes, it
> is often convinient to reference the main routing table multiple times - but
> omitting the default route. Using this patch and a modified "ip" utility, this
> can be achieved by using the following command sequence:
> 
>   $ ip route add table secuplink default via 10.42.23.1
> 
>   $ ip rule add pref 100            table main prefixlength 1
>   $ ip rule add pref 150 fwmark 0xA table secuplink
> 
> With this setup, packets marked 0xA will be processed by the additional routing
> table "secuplink", but only if no suitable route in the main routing table can
> be found. By using a minimal prefixlength of 1, the default route (/0) of the
> table "main" is hidden to packets processed by rule 100; packets traveling to
> destinations with more specific routing entries are processed as usual.
> 
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>

Applied, thanks.
