From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 12:44:34 -0400 (EDT)
Message-ID: <20150323.124434.1526209682898584518.davem@davemloft.net>
References: <20150322121755.GH1185@casper.infradead.org>
	<20150323000954.GB9507@gondor.apana.org.au>
	<20150323083319.GB16023@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	kaber@trash.net, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbbCWQoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 12:44:37 -0400
In-Reply-To: <20150323083319.GB16023@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 23 Mar 2015 08:33:19 +0000

> I don't get why almost nobody would want shrinking. I agree that for
> tables like TCP hash tables, once you have grown you want to keep that
> table size because the load is likely to come back. But we will also
> have lots of users such as the Netlink socket with a table per protocol
> where not shrinking results in giving the user the ability to waste
> memory indefinitely for no gain.

The user can't do this with TCP?  Why is netlink only susceptible?

The only plausible argument for shrinking I've ever heard of is the
nft_hash case, and there that code can _explicitly_ ask for a shrink
after it has made a major table modification.

That puts all of the smarts for when to shrink where the knowledge
resides, and in this case that's the user.
